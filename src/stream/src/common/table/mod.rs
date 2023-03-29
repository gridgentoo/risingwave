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

pub mod state_table;
mod watermark;
pub use watermark::{WatermarkBufferByEpoch, WatermarkBufferStrategy};

#[cfg(test)]
pub mod test_state_table;
#[cfg(test)]
pub mod test_storage_table;
#[cfg(test)]
mod test_utils;
