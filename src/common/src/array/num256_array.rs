// Copyright 2023 RisingWave Labs
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

use std::io::{Cursor, Read};
use std::mem::size_of;

use ethnum::I256;
use risingwave_pb::common::buffer::CompressionType;
use risingwave_pb::common::Buffer;
use risingwave_pb::data::PbArray;

use crate::array::{Array, ArrayBuilder, ArrayImpl, ArrayResult};
use crate::buffer::{Bitmap, BitmapBuilder};
use crate::collection::estimate_size::EstimateSize;
use crate::types::num256::{Int256, Int256Ref};
use crate::types::Scalar;

#[derive(Debug)]
pub struct Int256ArrayBuilder {
    bitmap: BitmapBuilder,
    data: Vec<I256>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Int256Array {
    bitmap: Bitmap,
    data: Vec<I256>,
}

impl Array for Int256Array {
    type Builder = Int256ArrayBuilder;
    type OwnedItem = Int256;
    type RefItem<'a> = Int256Ref<'a>;

    unsafe fn raw_value_at_unchecked(&self, idx: usize) -> Self::RefItem<'_> {
        Int256Ref(self.data.get_unchecked(idx))
    }

    fn len(&self) -> usize {
        self.data.len()
    }

    fn to_protobuf(&self) -> PbArray {
        let mut output_buffer = Vec::<u8>::with_capacity(self.len() * Int256::size());

        for v in self.iter() {
            v.map(|node| node.to_protobuf(&mut output_buffer));
        }

        let buffer = Buffer {
            compression: CompressionType::None as i32,
            body: output_buffer,
        };

        PbArray {
            null_bitmap: Some(self.null_bitmap().to_protobuf()),
            values: vec![buffer],
            array_type: Int256::array_type() as i32,
            struct_array_data: None,
            list_array_data: None,
        }
    }

    fn null_bitmap(&self) -> &Bitmap {
        &self.bitmap
    }

    fn into_null_bitmap(self) -> Bitmap {
        self.bitmap
    }

    fn set_bitmap(&mut self, bitmap: Bitmap) {
        self.bitmap = bitmap;
    }

    fn create_builder(&self, capacity: usize) -> super::ArrayBuilderImpl {
        let array_builder = Self::Builder::new(capacity);
        super::ArrayBuilderImpl::Int256(array_builder)
    }
}
impl ArrayBuilder for Int256ArrayBuilder {
    type ArrayType = Int256Array;

    fn with_meta(capacity: usize, _meta: super::ArrayMeta) -> Self {
        Self {
            bitmap: BitmapBuilder::with_capacity(capacity),
            data: Vec::with_capacity(capacity),
        }
    }

    fn append_n(&mut self, n: usize, value: Option<<Self::ArrayType as Array>::RefItem<'_>>) {
        match value {
            Some(x) => {
                self.bitmap.append_n(n, true);
                self.data
                    .extend(std::iter::repeat(x).take(n).map(|x| x.0.clone()));
            }
            None => {
                self.bitmap.append_n(n, false);
                self.data
                    .extend(std::iter::repeat(Int256::default().into_inner()).take(n));
            }
        }
    }

    fn append_array(&mut self, other: &Self::ArrayType) {
        for bit in other.bitmap.iter() {
            self.bitmap.append(bit);
        }
        self.data.extend_from_slice(&other.data);
    }

    fn pop(&mut self) -> Option<()> {
        self.data.pop().map(|_| self.bitmap.pop().unwrap())
    }

    fn finish(self) -> Self::ArrayType {
        Self::ArrayType {
            bitmap: self.bitmap.finish(),
            data: self.data,
        }
    }
}
impl<'a> FromIterator<Option<Int256Ref<'a>>> for Int256Array {
    fn from_iter<T: IntoIterator<Item = Option<Int256Ref<'a>>>>(iter: T) -> Self {
        let iter = iter.into_iter();
        let mut builder = <Self as Array>::Builder::new(iter.size_hint().0);
        for i in iter {
            builder.append(i);
        }
        builder.finish()
    }
}
impl Int256Array {
    pub fn from_protobuf(array: &PbArray, cardinality: usize) -> ArrayResult<ArrayImpl> {
        ensure!(
            array.get_values().len() == 1,
            "Must have only 1 buffer in array"
        );

        let buf = array.get_values()[0].get_body().as_slice();

        let mut builder = <Int256ArrayBuilder>::new(cardinality);
        let bitmap: Bitmap = array.get_null_bitmap()?.into();
        let mut cursor = Cursor::new(buf);
        for not_null in bitmap.iter() {
            if not_null {
                let mut buf = [0u8; Int256::size()];
                cursor.read_exact(&mut buf)?;
                let item = <Int256>::from_be_bytes(buf);
                builder.append(Some(item.as_scalar_ref()));
            } else {
                builder.append(None);
            }
        }
        let arr = builder.finish();
        ensure_eq!(arr.len(), cardinality);

        Ok(arr.into())
    }
}
impl EstimateSize for Int256Array {
    fn estimated_heap_size(&self) -> usize {
        self.bitmap.estimated_heap_size() + self.data.capacity() * size_of::<I256>()
    }
}
