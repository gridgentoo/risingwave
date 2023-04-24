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

use dyn_clone::DynClone;
use itertools::Itertools;
use risingwave_common::array::{ArrayBuilderImpl, DataChunk};
use risingwave_common::types::{DataType, DataTypeName};

use crate::{ExprError, Result};

mod approx_count_distinct;
mod array_agg;
mod count_star;
mod def;
mod filter;
mod general;
mod general_sorted_grouper;
mod string_agg;

pub use self::def::*;
use self::filter::*;
pub use self::general_sorted_grouper::{create_sorted_grouper, BoxedSortedGrouper, EqGroups};

/// An `Aggregator` supports `update` data and `output` result.
#[async_trait::async_trait]
pub trait Aggregator: Send + DynClone + 'static {
    fn return_type(&self) -> DataType;

    /// `update_single` update the aggregator with a single row with type checked at runtime.
    async fn update_single(&mut self, input: &DataChunk, row_id: usize) -> Result<()> {
        self.update_multi(input, row_id, row_id + 1).await
    }

    /// `update_multi` update the aggregator with multiple rows with type checked at runtime.
    async fn update_multi(
        &mut self,
        input: &DataChunk,
        start_row_id: usize,
        end_row_id: usize,
    ) -> Result<()>;

    /// `output` the aggregator to `ArrayBuilder` with input with type checked at runtime.
    /// After `output` the aggregator is reset to initial state.
    fn output(&mut self, builder: &mut ArrayBuilderImpl) -> Result<()>;
}

dyn_clone::clone_trait_object!(Aggregator);

pub type BoxedAggState = Box<dyn Aggregator>;

/// Build an `Aggregator` from `AggCall`.
pub fn build(agg_call: AggCall) -> Result<BoxedAggState> {
    // NOTE: The function signature is checked by `AggCall::infer_return_type` in the frontend.

    let args = (agg_call.args.arg_types().iter())
        .map(|t| t.into())
        .collect::<Vec<DataTypeName>>();
    let desc = crate::sig::agg::AGG_FUNC_SIG_MAP
        .get(agg_call.kind, &args, (&agg_call.return_type).into())
        .ok_or_else(|| {
            ExprError::UnsupportedFunction(format!(
                "{:?}({}) -> {:?}",
                agg_call.kind,
                (agg_call.args.arg_types().iter())
                    .map(|t| format!("{:?}", t))
                    .join(", "),
                agg_call.return_type,
            ))
        })?;
    let filter = agg_call.filter.clone();
    let mut aggregator = (desc.build)(agg_call)?;

    // wrap the agg state in a `Filter` if needed
    if let Some(expr) = filter {
        aggregator = Box::new(Filter::new(expr, aggregator));
    };

    Ok(aggregator)
}