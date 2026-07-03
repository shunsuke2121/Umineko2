---
name: network-topology-rocketleague
description: "User's home network is double-NAT'd on au/KDDI fiber; relevant to game lag and network troubleshooting"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7dec0720-c222-45c8-be5c-6d0f687258c7
---

User plays Rocket League on Steam and reported it feeling "重い" (laggy) even on JP servers (investigated 2026-06-20).

Network facts discovered:
- Wired via Realtek PCIe 2.5GbE (links at 1 Gbps). PC IP 172.16.232.141, gateway 172.16.232.1.
- **Double NAT confirmed**: PC's gateway (172.16.x) sits behind a second router (192.168.200.5) before reaching au/KDDI backbone (spcBBAR002-1.bb.kddi.ne.jp). Two RFC1918 hops in series.
- Base latency to internet is healthy: ~24ms, 0% loss, ~3ms jitter. A +16ms jump appears at the KDDI access hop (possible PPPoE congestion vs IPoE/v6プラス).
- Raw ping (24ms) is actually fine for RL — so "重さ" is more likely connection-quality/NAT type, background app contention (Discord overlay/HW accel, Spotify, Chrome), or streaming load, not framerate. RL graphics already lean (VSync off, 1080p, low detail, RTX 3060 Ti).
- `NetworkThrottlingIndex` was still default `10` (throttled); user declined the UAC to set it to 0xffffffff.

Streaming rig present (OBS/VOICEVOX/OneComme etc.) — see [[streaming-setup-note-articles]]. When playing + streaming on the same RTX 3060 Ti, encoder/GPU contention is a plausible stutter source.

**RESOLVED 2026-06-20 — root cause was CLIENT-side, not network.** Captured the live game server from RL's Launch.log (Documents\My Games\Rocket League\TAGame\Logs\Launch.log — logs `GameURL="<ip:port>"`, ServerName, Region). Server was 35.78.159.96:7810 (AWS ap-northeast-1 Tokyo, Region=JPN). Ping to it: **19ms, 0% loss, 2ms jitter** = perfect. Network fully cleared. The "ボールがギザギザ" (jaggy ball) was caused by:
1. **NVIDIA ShadowPlay Instant Replay recording 24/7** — `nvcontainer` using NVENC ~20% in background → periodic micro-stutter. Turn off Instant Replay (Alt+Z overlay) when not clipping.
2. **VSync OFF on a 165Hz monitor, uncapped FPS → screen tearing.** Fix: enable G-SYNC + cap FPS ~160 + Low Latency On (NVIDIA Control Panel), or turn VSync on.
3. Secondary: Discord (11 procs, overlay + HW accel) — disable in-game overlay & HW accel.
Double-NAT is irrelevant to this symptom (only matters for NAT type / ranked matchmaking). RL priority can't be changed (anti-cheat denies access). Useful trick: read Launch.log to get the exact server IP for any future RL net test.

**Follow-up**: user clarified real symptom = ball-trajectory rubber-banding + laggy hit-reg, in-game ping ~40ms (vs 19ms ICMP — normal RL overhead, not "broken"). Cause = jitter/local stalls, not raw latency. Tweaks APPLIED 2026-06-20 (user approved one UAC): NIC `Interrupt Moderation = Disabled` (Realtek PCIe 2.5GbE) to cut jitter; `NetworkThrottlingIndex = 0xFFFFFFFF` (needs REBOOT to take effect); `OneFrameThreadLag=False` in TASystemSettings.ini and the .ini set **read-only** so RL can't overwrite (revert: `(Get-Item $cfg).IsReadOnly=$false` — note: while locked, in-game video setting changes won't save). Still TODO by user: turn off ShadowPlay Instant Replay (Alt+Z), Discord overlay + HW accel off. Restart RL for OneFrameThreadLag; reboot for NetworkThrottlingIndex.

**Final verdict on "make ping faster" (2026-06-20, user asked to lower ping, then went to sleep):** Nothing left to do — ping is at the physical floor. Access line is pristine: 2.6ms to KDDI near-node (27.86.18.173), 0% loss, 2ms jitter; 23-24ms to Cloudflare/Google; 19ms to the Tokyo game server. The +16-20ms is KDDI backbone/distance beyond the user's local node — not fixable by the user. Realtek driver exposes NO further latency knobs (no EEE/Green Ethernet/Flow Control; only Interrupt Moderation, already disabled). No global IPv6 → upstream likely IPv4 PPPoE. In-game 40ms = RL protocol overhead over the 19ms network ping; unremovable. Only remaining (speculative, low-payoff) lever = IPoE/v6プラス migration + de-double-NAT (router/ISP, needs user awake); benefit is mainly evening-congestion resistance + native IPv6 + NAT-type Open, NOT a meaningfully lower number. Do NOT re-investigate from scratch next time — the line is already optimal.
