## Plan: Optimize Multi-Chunk Loading Performance

**TL;DR:**  
Your system uses a pool of Sampler and Renderer actors to process chunk generation and rendering in parallel, but chunk loading is still slower than desired when loading multiple chunks. The main bottlenecks are likely due to per-chunk batching, frequent `task.wait()` calls, and possibly underutilized parallelism. The plan will focus on profiling, tuning batch sizes, and maximizing parallel actor usage.

---

**Steps**

### Phase 1: Profiling and Bottleneck Identification
1. **Profile Chunk Loading**
   - Add timing logs to chunk sampling and rendering (start/end per chunk and per batch).
   - Measure time spent in `task.wait()` and per-batch processing.
2. **Analyze Actor Utilization**
   - Log which Sampler/Renderer actors are busy during multi-chunk loads.
   - Check if all actors are used or if some are idle.

3. **Note on Event Handoff Bottleneck**
  If all Sampler actors fire a BindableEvent that is only handled by the main thread, the handoff from sampling to rendering becomes serialized, creating a bottleneck. This means even if sampling is parallel, rendering cannot start for multiple chunks at once, as the main thread processes each event sequentially.
  
  **Potential solutions:**
  - Allow Samplers to directly notify Renderer actors, bypassing the main thread for the handoff.
  - Use multiple event handlers or a handler pool to distribute the load.
  - Batch completed chunks before dispatching to renderers to reduce event overhead.
  
  


### Phase 2: Batch Size and Yield Optimization
3. **Tune Batch Sizes**
   - Experiment with increasing `T_SAMPLE_BATCH_SIZE`, `E_SAMPLE_BATCH_SIZE`, `T_RENDER_BATCH_SIZE`, and `E_RENDER_BATCH_SIZE` in GenerationVariables.
   - Monitor impact on both single and multi-chunk load times.
4. **Reduce Unnecessary Yields**
   - Review logic around `task.wait()` in SamplerModule and VoxelModule.
   - Only yield when absolutely necessary (e.g., after a large batch, not every small loop).

### Phase 3: Parallelism and Scaling
5. **Increase Actor Pool Size**
   - Test increasing `GENERATION_SAMPLERS` and `GENERATION_RENDERERS` to better match the number of chunks loaded in parallel.
   - ~~Ensure the system can handle more actors without hitting Roblox limits.~~
6. **Optimize Chunk Request Scheduling**
   - ~~If chunk requests are still serialized, implement a queue or scheduler to dispatch as many parallel requests as possible up to the actor pool limit.~~

### Phase 4: Verification and Regression Testing
7. **Test with Various Chunk Counts**
   - Benchmark loading times for 1, 4, 9, 16, etc., chunks.
   - Compare before/after metrics.
8. **Monitor for Side Effects**
   - Watch for increased memory usage, server lag, or instability as parallelism increases.

---

**Relevant files**
- `src/server/TerrainSystem/Manager.lua` — Actor pool setup, chunk request logic
- `src/server/TerrainSystem/Sampling/SamplerModule.lua` — Sampling logic, batching, and yielding
- `src/server/TerrainSystem/Rendering/VoxelModule.lua` — Rendering logic, batching, and yielding
- `src/server/TerrainSystem/Data/GenerationVariables.lua` — Batch size and actor pool configuration

---

**Verification**
1. Add and review timing logs for chunk sampling and rendering.
2. Confirm all actors are utilized during multi-chunk loads.
3. Benchmark chunk load times before and after each change.
4. Validate system stability and absence of new errors or lag.

---

**Decisions**
- Focus is on maximizing parallelism and minimizing unnecessary yields.
- No major algorithmic changes unless profiling reveals deeper issues.
- Scope excludes rewriting core sampling/rendering logic unless proven necessary.

---

**Further Considerations**
1. If Roblox actor/thread limits are reached, consider chunk prioritization or dynamic throttling.
2. If memory usage spikes, monitor for leaks or excessive data retention.
3. If single-chunk speed drops, revisit batch size and yield balance.

---



