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

use risingwave_hummock_sdk::key_range::KeyRangeCommon;
use risingwave_pb::hummock::{
    HummockVersion, Level, LevelType, PinnedSnapshotsSummary, PinnedVersionsSummary,
};
use risingwave_rpc_client::HummockMetaClient;

use crate::CtlContext;

pub async fn list_version(context: &CtlContext) -> anyhow::Result<()> {
    let meta_client = context.meta_client().await?;
    let version = meta_client.get_current_version().await?;
    println!("{:#?}", version);
    sanity_check(&version);
    Ok(())
}

fn sanity_check(hummock_version: &HummockVersion) {
    for levels in hummock_version.levels.values() {
        for level in &levels.l0.as_ref().unwrap().sub_levels {
            sanity_check_level(format!("{}-{}", 0, level.level_idx), level);
        }
        for level in &levels.levels {
            sanity_check_level(format!("{}", level.level_idx), level);
        }
    }
    println!("sanity check done");
}

fn sanity_check_level(level_idx: String, level: &Level) {
    use risingwave_hummock_sdk::prost_key_range::KeyRangeExt;
    use risingwave_hummock_sdk::KeyComparator;
    if level.level_type() == LevelType::Overlapping {
        return;
    }
    for ii in 0..level.table_infos.len() {
        let left_sst = &level.table_infos[ii];
        for i in 0..ii {
            let left_left_sst = &level.table_infos[i];
            if left_left_sst.key_range.as_ref().unwrap().sstable_overlap(&left_sst.key_range.as_ref().unwrap()) {
                tracing::error!(
                    "E0 level {} invalid SSTs. left-left: {:#?} left: {:#?}",
                    level_idx,
                    left_left_sst,
                    left_sst,
                );
            }
            if left_left_sst.key_range.as_ref().unwrap().full_key_overlap(&left_sst.key_range.as_ref().unwrap()) {
                tracing::error!(
                    "E1 level {} invalid SSTs. left-left: {:#?} left: {:#?}",
                    level_idx,
                    left_left_sst,
                    left_sst,
                );
            }
        }
        if ii + 1 == level.table_infos.len() {
            continue;
        }
        let right_sst = &level.table_infos[ii + 1];
        if left_sst.key_range.as_ref().unwrap().compare(right_sst.key_range.as_ref().unwrap()) != std::cmp::Ordering::Less  {
            tracing::error!(
                "E2 level {} invalid SSTs. left: {:#?} right: {:#?}",
                level_idx,
                left_sst,
                right_sst,
            );
        }
        if KeyComparator::compare_encoded_full_key(&left_sst.key_range.as_ref().unwrap().right, &right_sst.key_range.as_ref().unwrap().left) != std::cmp::Ordering::Less {
            tracing::error!(
                "E3 level {} invalid SSTs. left: {:#?} right: {:#?}",
                level_idx,
                left_sst,
                right_sst,
            );
        }
    }
}

pub async fn list_pinned_versions(context: &CtlContext) -> anyhow::Result<()> {
    let meta_client = context.meta_client().await?;
    let PinnedVersionsSummary {
        mut pinned_versions,
        workers,
    } = meta_client
        .risectl_get_pinned_versions_summary()
        .await?
        .summary
        .unwrap();
    pinned_versions.sort_by_key(|v| v.min_pinned_id);
    for pinned_version in pinned_versions {
        match workers.get(&pinned_version.context_id) {
            None => {
                println!(
                    "Worker {} may have been dropped, min_pinned_version_id {}",
                    pinned_version.context_id, pinned_version.min_pinned_id
                );
            }
            Some(worker) => {
                println!(
                    "Worker {} type {} min_pinned_version_id {}",
                    pinned_version.context_id,
                    worker.r#type().as_str_name(),
                    pinned_version.min_pinned_id
                );
            }
        }
    }
    Ok(())
}

pub async fn list_pinned_snapshots(context: &CtlContext) -> anyhow::Result<()> {
    let meta_client = context.meta_client().await?;
    let PinnedSnapshotsSummary {
        mut pinned_snapshots,
        workers,
    } = meta_client
        .risectl_get_pinned_snapshots_summary()
        .await?
        .summary
        .unwrap();
    pinned_snapshots.sort_by_key(|s| s.minimal_pinned_snapshot);
    for pinned_snapshot in pinned_snapshots {
        match workers.get(&pinned_snapshot.context_id) {
            None => {
                println!(
                    "Worker {} may have been dropped, min_pinned_snapshot {}",
                    pinned_snapshot.context_id, pinned_snapshot.minimal_pinned_snapshot
                );
            }
            Some(worker) => {
                println!(
                    "Worker {} type {} min_pinned_snapshot {}",
                    pinned_snapshot.context_id,
                    worker.r#type().as_str_name(),
                    pinned_snapshot.minimal_pinned_snapshot
                );
            }
        }
    }
    Ok(())
}
