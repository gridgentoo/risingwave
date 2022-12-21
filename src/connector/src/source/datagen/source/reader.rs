// Copyright 2023 Singularity Data
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

use std::collections::HashMap;

use anyhow::Result;
use async_trait::async_trait;
use futures::StreamExt;
use itertools::zip_eq;
use risingwave_common::field_generator::FieldGeneratorImpl;

use super::generator::DatagenEventGenerator;
use crate::source::datagen::source::SEQUENCE_FIELD_KIND;
use crate::source::datagen::{DatagenProperties, DatagenSplit};
use crate::source::{
    spawn_data_generation_stream, BoxSourceStream, Column, ConnectorState, DataType, SplitId,
    SplitImpl, SplitMetaData, SplitReader,
};

pub struct DatagenSplitReader {
    generator: DatagenEventGenerator,
    assigned_split: DatagenSplit,
}

#[async_trait]
impl SplitReader for DatagenSplitReader {
    type Properties = DatagenProperties;

    async fn new(
        properties: DatagenProperties,
        state: ConnectorState,
        columns: Option<Vec<Column>>,
    ) -> Result<Self> {
        let mut assigned_split = DatagenSplit::default();
        let mut split_id: SplitId = "".into();
        let mut events_so_far = u64::default();
        if let Some(splits) = state {
            tracing::debug!("Splits for datagen found! {:?}", splits);
            for split in splits {
                // TODO: currently, assume there's only on split in one reader
                split_id = split.id();
                if let SplitImpl::Datagen(n) = split {
                    if let Some(s) = n.start_offset {
                        // start_offset in `SplitImpl` indicates the latest successfully generated
                        // index, so here we use start_offset+1
                        events_so_far = s + 1;
                    };
                    assigned_split = n;
                    break;
                }
            }
        }

        let split_index = assigned_split.split_index as u64;
        let split_num = assigned_split.split_num as u64;

        let rows_per_second = properties.rows_per_second;
        let fields_option_map = properties.fields;

        // check columns
        assert!(columns.as_ref().is_some());
        let columns = columns.unwrap();

        // parse field connector option to build FieldGeneratorImpl
        // for example:
        // create materialized source s1  (
        //     f_sequence INT,
        //     f_random INT,
        //    ) with (
        //     'connector' = 'datagen',
        // 'fields.f_sequence.kind'='sequence',
        // 'fields.f_sequence.start'='1',
        // 'fields.f_sequence.end'='1000',

        // 'fields.f_random.min'='1',
        // 'fields.f_random.max'='1000',
        // 'fields.f_random.seed'='12345',

        // 'fields.f_random_str.length'='10'
        // )
        let mut fields_vec = vec![];
        for column in columns {
            let name = column.name.clone();
            let gen = generator_from_data_type(
                column.data_type.clone(),
                &fields_option_map,
                &name,
                split_index,
                split_num,
            )?;
            fields_vec.push(gen);
        }
        let generator = DatagenEventGenerator::new(
            fields_vec,
            rows_per_second,
            events_so_far,
            split_id,
            split_num,
            split_index,
        )?;

        Ok(DatagenSplitReader {
            generator,
            assigned_split,
        })
    }

    fn into_stream(self) -> BoxSourceStream {
        // Will buffer at most 4 event chunks.
        const BUFFER_SIZE: usize = 4;
        spawn_data_generation_stream(self.generator.into_stream(), BUFFER_SIZE).boxed()
    }
}

fn generator_from_data_type(
    data_type: DataType,
    fields_option_map: &HashMap<String, String>,
    name: &String,
    split_index: u64,
    split_num: u64,
) -> Result<FieldGeneratorImpl> {
    let random_seed_key = format!("fields.{}.seed", name);
    let random_seed: u64 = match fields_option_map
        .get(&random_seed_key)
        .map(|s| s.to_string())
    {
        Some(seed) => {
            match seed.parse::<u64>() {
                // we use given seed xor split_index to make sure every split has different
                // seed
                Ok(seed) => seed ^ split_index,
                Err(e) => {
                    tracing::warn!(
                        "cannot parse {:?} to u64 due to {:?}, will use {:?} as random seed",
                        seed,
                        e,
                        split_index
                    );
                    split_index
                }
            }
        }
        None => split_index,
    };
    match data_type {
        DataType::Timestamp => {
            let max_past_key = format!("fields.{}.max_past", name);
            let max_past_value = fields_option_map.get(&max_past_key).map(|s| s.to_string());
            let max_past_mode_key = format!("fields.{}.max_past_mode", name);
            let max_past_mode_value = fields_option_map
                .get(&max_past_mode_key)
                .map(|s| s.to_lowercase());

            FieldGeneratorImpl::with_timestamp(max_past_value, max_past_mode_value, random_seed)
        }
        DataType::Varchar => {
            let length_key = format!("fields.{}.length", name);
            let length_value = fields_option_map.get(&length_key).map(|s| s.to_string());
            FieldGeneratorImpl::with_varchar(length_value, random_seed)
        }
        DataType::Struct(struct_type) => {
            let struct_fields = zip_eq(struct_type.field_names.clone(), struct_type.fields.clone())
                .map(|(field_name, data_type)| {
                    let gen = generator_from_data_type(
                        data_type,
                        fields_option_map,
                        &format!("{}.{}", name, field_name),
                        split_index,
                        split_num,
                    )?;
                    Ok((field_name, gen))
                })
                .collect::<Result<_>>()?;
            FieldGeneratorImpl::with_struct_fields(struct_fields)
        }
        DataType::List { datatype } => {
            let length_key = format!("fields.{}.length", name);
            let length_value = fields_option_map.get(&length_key).map(|s| s.to_string());
            let generator = generator_from_data_type(
                *datatype,
                fields_option_map,
                &format!("{}._", name),
                split_index,
                split_num,
            )?;
            FieldGeneratorImpl::with_list(generator, length_value)
        }
        _ => {
            let kind_key = format!("fields.{}.kind", name);
            if let Some(kind) = fields_option_map.get(&kind_key) && kind.as_str() == SEQUENCE_FIELD_KIND {
                let start_key = format!("fields.{}.start", name);
                let end_key = format!("fields.{}.end", name);
                let start_value =
                    fields_option_map.get(&start_key).map(|s| s.to_string());
                let end_value = fields_option_map.get(&end_key).map(|s| s.to_string());
                FieldGeneratorImpl::with_number_sequence(
                    data_type,
                    start_value,
                    end_value,
                    split_index,
                    split_num
                )
            } else {
                let min_key = format!("fields.{}.min", name);
                let max_key = format!("fields.{}.max", name);
                let min_value = fields_option_map.get(&min_key).map(|s| s.to_string());
                let max_value = fields_option_map.get(&max_key).map(|s| s.to_string());
                FieldGeneratorImpl::with_number_random(
                    data_type,
                    min_value,
                    max_value,
                    random_seed
                )
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use std::sync::Arc;

    use maplit::{convert_args, hashmap};
    use risingwave_common::array::StructValue;
    use risingwave_common::row::OwnedRow;
    use risingwave_common::types::struct_type::StructType;
    use risingwave_common::types::ScalarImpl;

    use super::*;

    fn turn_payload_into_boxed_owned_row(payload: &[u8]) -> Box<OwnedRow> {
        unsafe { Box::from_raw(payload.as_ptr() as *mut OwnedRow) }
    }

    #[allow(clippy::excessive_precision)]
    #[tokio::test]
    async fn test_generator() -> Result<()> {
        let mock_datum = vec![
            Column {
                name: "random_int".to_string(),
                data_type: DataType::Int32,
            },
            Column {
                name: "random_float".to_string(),
                data_type: DataType::Float32,
            },
            Column {
                name: "sequence_int".to_string(),
                data_type: DataType::Int32,
            },
            Column {
                name: "struct".to_string(),
                data_type: DataType::Struct(Arc::new(StructType {
                    fields: vec![DataType::Int32],
                    field_names: vec!["random_int".to_string()],
                })),
            },
        ];
        let state = Some(vec![SplitImpl::Datagen(DatagenSplit {
            split_index: 0,
            split_num: 1,
            start_offset: None,
        })]);
        let properties = DatagenProperties {
            split_num: None,
            rows_per_second: 10,
            fields: convert_args!(hashmap!(
                "fields.random_int.min" => "1",
                "fields.random_int.max" => "1000",
                "fields.random_int.seed" => "12345",

                "fields.random_float.min" => "1",
                "fields.random_float.max" => "1000",
                "fields.random_float.seed" => "12345",

                "fields.sequence_int.kind" => "sequence",
                "fields.sequence_int.start" => "1",
                "fields.sequence_int.end" => "1000",

                "fields.struct.random_int.min" => "1001",
                "fields.struct.random_int.max" => "2000",
                "fields.struct.random_int.seed" => "12345",
            )),
        };

        let mut reader = DatagenSplitReader::new(properties, state, Some(mock_datum))
            .await?
            .into_stream();
        let random_float = Some(ScalarImpl::Float32(533.1488647460938.into()));
        let random_int = Some(ScalarImpl::Int32(533));
        let sequence_int = Some(ScalarImpl::Int32(1));
        let struct_int = Some(ScalarImpl::Struct(StructValue::new(vec![
            ScalarImpl::Int32(1533).into(),
        ])));
        // The order should be the same as `mock_datum`
        let expected_row = OwnedRow::new(vec![random_int, random_float, sequence_int, struct_int]);

        let msg = reader.next().await.unwrap().unwrap();
        let real_row: Box<OwnedRow> =
            turn_payload_into_boxed_owned_row(msg[0].payload.as_ref().unwrap());
        assert_eq!(&expected_row, real_row.as_ref());
        Ok(())
    }

    #[tokio::test]
    async fn test_random_deterministic() -> Result<()> {
        let mock_datum = vec![
            Column {
                name: "_".to_string(),
                data_type: DataType::Int64,
            },
            Column {
                name: "random_int".to_string(),
                data_type: DataType::Int32,
            },
        ];
        let state = Some(vec![SplitImpl::Datagen(DatagenSplit {
            split_index: 0,
            split_num: 1,
            start_offset: None,
        })]);
        let properties = DatagenProperties {
            split_num: None,
            rows_per_second: 10,
            fields: convert_args!(hashmap!(
                "fields.random_int.min" => "1",
                "fields.random_int.max" => "1000",
                "fields.random_int.seed" => "12345",
            )),
        };
        let stream = DatagenSplitReader::new(properties.clone(), state, Some(mock_datum.clone()))
            .await?
            .into_stream();
        let v1 = stream.skip(1).next().await.unwrap()?;
        let v1_rows: Vec<Box<OwnedRow>> = v1
            .into_iter()
            .map(|source_msg| turn_payload_into_boxed_owned_row(&source_msg.payload.unwrap()))
            .collect::<Vec<_>>();

        let state = Some(vec![SplitImpl::Datagen(DatagenSplit {
            split_index: 0,
            split_num: 1,
            start_offset: Some(9),
        })]);
        let mut stream = DatagenSplitReader::new(properties, state, Some(mock_datum))
            .await?
            .into_stream();
        let v2 = stream.next().await.unwrap()?;
        let v2_rows: Vec<Box<OwnedRow>> = v2
            .into_iter()
            .map(|source_msg| turn_payload_into_boxed_owned_row(&source_msg.payload.unwrap()))
            .collect::<Vec<_>>();

        // Because now SourceMassage's payload contain Box's layout,
        // so we have to turn payload into OwnedRow before comparing them.
        assert_eq!(v1_rows, v2_rows);
        Ok(())
    }
}
