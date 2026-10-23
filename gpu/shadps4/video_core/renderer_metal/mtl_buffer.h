// SPDX-License-Identifier: GPL-2.0-or-later
// bbport: MTLBuffer creation for the buffer cache (Metal-native renderer).

#pragma once

#include <string_view>
#include "common/types.h"
#include "video_core/renderer_metal/mtl_memory_type.h"
#include "video_core/renderer_metal/mtl_object.h"

namespace Metal {

class Device;

/// Creates an MTLBuffer of `size` bytes: DeviceLocal is private storage (untracked unless
/// Device::HazardTracking(): Encoders order it, mtl_order.h), HostUncached is shared
/// and write-combined, HostCached and Stream are shared. Returns an empty Object on failure.
/// `gpu_address` receives the buffer's GPU address, `contents` the CPU pointer (null for
/// DeviceLocal). `host_view`, if given, receives the CPU pointer of a lazy DeviceLocal buffer
/// (the guest arena: shared storage), for reads of GPU-written data once its command completed;
/// code that treats `contents` as an upload path does not see it.
Object CreateBuffer(Device& device, u64 size, VideoCore::MemoryType type, std::string_view label,
                    u64* gpu_address, u8** contents, u8** host_view = nullptr);

} // namespace Metal
