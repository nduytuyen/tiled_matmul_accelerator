; ModuleID = 'E:/CENTOS7/shared/tiled_matmul_accelerator/mmult_accel_hls/solution1/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

; Function Attrs: noinline
define void @apatb_mmult_accel_ir(i8* noalias nocapture nonnull readonly %A, i8* noalias nocapture nonnull readonly %B, i32* noalias nocapture nonnull %C, i32 %N, i32 %K, i32 %M, i32 %update_A) local_unnamed_addr #0 {
entry:
  %malloccall = tail call i8* @malloc(i64 49152)
  %A_copy = bitcast i8* %malloccall to [49152 x i8]*
  %malloccall1 = tail call i8* @malloc(i64 589824)
  %B_copy = bitcast i8* %malloccall1 to [589824 x i8]*
  %malloccall2 = tail call i8* @malloc(i64 196608)
  %C_copy = bitcast i8* %malloccall2 to [49152 x i32]*
  %0 = bitcast i8* %A to [49152 x i8]*
  %1 = bitcast i8* %B to [589824 x i8]*
  %2 = bitcast i32* %C to [49152 x i32]*
  call fastcc void @copy_in([49152 x i8]* nonnull %0, [49152 x i8]* %A_copy, [589824 x i8]* nonnull %1, [589824 x i8]* %B_copy, [49152 x i32]* nonnull %2, [49152 x i32]* %C_copy)
  %3 = getelementptr inbounds [49152 x i32], [49152 x i32]* %C_copy, i32 0, i32 0
  call void @apatb_mmult_accel_hw(i8* %malloccall, i8* %malloccall1, i32* %3, i32 %N, i32 %K, i32 %M, i32 %update_A)
  call void @copy_back([49152 x i8]* %0, [49152 x i8]* %A_copy, [589824 x i8]* %1, [589824 x i8]* %B_copy, [49152 x i32]* %2, [49152 x i32]* %C_copy)
  tail call void @free(i8* %malloccall)
  tail call void @free(i8* %malloccall1)
  tail call void @free(i8* %malloccall2)
  ret void
}

declare noalias i8* @malloc(i64) local_unnamed_addr

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @copy_in([49152 x i8]* noalias readonly, [49152 x i8]* noalias, [589824 x i8]* noalias readonly, [589824 x i8]* noalias, [49152 x i32]* noalias readonly, [49152 x i32]* noalias) unnamed_addr #1 {
entry:
  call fastcc void @onebyonecpy_hls.p0a49152i8([49152 x i8]* %1, [49152 x i8]* %0)
  call fastcc void @onebyonecpy_hls.p0a589824i8([589824 x i8]* %3, [589824 x i8]* %2)
  call fastcc void @onebyonecpy_hls.p0a49152i32([49152 x i32]* %5, [49152 x i32]* %4)
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @onebyonecpy_hls.p0a49152i8([49152 x i8]* noalias, [49152 x i8]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [49152 x i8]* %0, null
  %3 = icmp eq [49152 x i8]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx1 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [49152 x i8], [49152 x i8]* %0, i64 0, i64 %for.loop.idx1
  %src.addr = getelementptr [49152 x i8], [49152 x i8]* %1, i64 0, i64 %for.loop.idx1
  %5 = load i8, i8* %src.addr, align 1
  store i8 %5, i8* %dst.addr, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx1, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 49152
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @onebyonecpy_hls.p0a589824i8([589824 x i8]* noalias, [589824 x i8]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [589824 x i8]* %0, null
  %3 = icmp eq [589824 x i8]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx1 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [589824 x i8], [589824 x i8]* %0, i64 0, i64 %for.loop.idx1
  %src.addr = getelementptr [589824 x i8], [589824 x i8]* %1, i64 0, i64 %for.loop.idx1
  %5 = load i8, i8* %src.addr, align 1
  store i8 %5, i8* %dst.addr, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx1, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 589824
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @onebyonecpy_hls.p0a49152i32([49152 x i32]* noalias, [49152 x i32]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [49152 x i32]* %0, null
  %3 = icmp eq [49152 x i32]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx1 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [49152 x i32], [49152 x i32]* %0, i64 0, i64 %for.loop.idx1
  %src.addr = getelementptr [49152 x i32], [49152 x i32]* %1, i64 0, i64 %for.loop.idx1
  %5 = load i32, i32* %src.addr, align 4
  store i32 %5, i32* %dst.addr, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx1, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 49152
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @copy_out([49152 x i8]* noalias, [49152 x i8]* noalias readonly, [589824 x i8]* noalias, [589824 x i8]* noalias readonly, [49152 x i32]* noalias, [49152 x i32]* noalias readonly) unnamed_addr #3 {
entry:
  call fastcc void @onebyonecpy_hls.p0a49152i8([49152 x i8]* %0, [49152 x i8]* %1)
  call fastcc void @onebyonecpy_hls.p0a589824i8([589824 x i8]* %2, [589824 x i8]* %3)
  call fastcc void @onebyonecpy_hls.p0a49152i32([49152 x i32]* %4, [49152 x i32]* %5)
  ret void
}

declare void @free(i8*) local_unnamed_addr

declare void @apatb_mmult_accel_hw(i8*, i8*, i32*, i32, i32, i32, i32)

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @copy_back([49152 x i8]* noalias, [49152 x i8]* noalias readonly, [589824 x i8]* noalias, [589824 x i8]* noalias readonly, [49152 x i32]* noalias, [49152 x i32]* noalias readonly) unnamed_addr #3 {
entry:
  call fastcc void @onebyonecpy_hls.p0a49152i32([49152 x i32]* %4, [49152 x i32]* %5)
  ret void
}

define void @mmult_accel_hw_stub_wrapper(i8*, i8*, i32*, i32, i32, i32, i32) #4 {
entry:
  %7 = bitcast i8* %0 to [49152 x i8]*
  %8 = bitcast i8* %1 to [589824 x i8]*
  %9 = bitcast i32* %2 to [49152 x i32]*
  call void @copy_out([49152 x i8]* null, [49152 x i8]* %7, [589824 x i8]* null, [589824 x i8]* %8, [49152 x i32]* null, [49152 x i32]* %9)
  %10 = bitcast [49152 x i8]* %7 to i8*
  %11 = bitcast [589824 x i8]* %8 to i8*
  %12 = bitcast [49152 x i32]* %9 to i32*
  call void @mmult_accel_hw_stub(i8* %10, i8* %11, i32* %12, i32 %3, i32 %4, i32 %5, i32 %6)
  call void @copy_in([49152 x i8]* null, [49152 x i8]* %7, [589824 x i8]* null, [589824 x i8]* %8, [49152 x i32]* null, [49152 x i32]* %9)
  ret void
}

declare void @mmult_accel_hw_stub(i8*, i8*, i32*, i32, i32, i32, i32)

attributes #0 = { noinline "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline norecurse "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline norecurse "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline norecurse "fpga.wrapper.func"="copyout" }
attributes #4 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!llvm.module.flags = !{!1, !2, !3}
!blackbox_cfg = !{!4}

!0 = !{!"clang version 7.0.0 "}
!1 = !{i32 2, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{}
