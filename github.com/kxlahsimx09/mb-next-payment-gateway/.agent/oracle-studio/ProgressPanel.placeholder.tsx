/**
 * ProgressPanel — PLACEHOLDER (campaign nextteam, C0 scaffold by brew-ops)
 * ----------------------------------------------------------------------------
 * This is a NON-FUNCTIONAL placeholder. The real panel lands in the
 * `Soul-Brews-Studio/oracle-studio` repo (src/pages/) as a follow-up PR, owned
 * by `next-pm` (coordinated with brew-ops, who owns oracle-studio connectivity).
 *
 * It exists here only to (a) pin the component contract next-pm will implement,
 * and (b) make the dashboard deliverable discoverable from the role scaffold.
 *
 * Contract: see ./progress-data-contract.md  (the JSON this panel consumes).
 * Data source: oracle-studio proxy -> Oracle HTTP API (:47778).
 *
 * Renders a per-story 4-gate board (SPEC / BUILD / REVIEW / VERIFY) + an
 * investigator-SEAL column + an epic rollup. Every cell links to its artifact.
 * "report from artifacts, never from a developer's word" (orchestrator §2a).
 */

// NOTE: imports intentionally omitted — this file is not wired into a build.
// In oracle-studio: `import { useOracle } from "../api/oracle";` etc.

type GateState = "empty" | "in-progress" | "green" | "blocked" | "unproven";

interface Gate {
  state: GateState;
  artifact: string | null;
}

interface StoryRow {
  id: string;          // e.g. "DEPOSIT-001"
  title: string;
  trust: "S2" | "S3" | "S4";
  gates: {
    spec: Gate;
    build: Gate;
    review: Gate & { verdict?: "approve" | "request-changes" };
    verify: Gate & {
      tester: Gate & { run_sha?: string };
      investigator: Gate & { v1?: boolean };
    };
  };
}

interface EpicRollup {
  id: string;
  title: string;
  rollup: GateState;
  seal: {
    state: "none" | "withheld" | "issued";
    seal_run_sha: string | null;
    learning_id: string | null;
    deferred_stories: string[];
  };
  stories: StoryRow[];
}

interface ProgressContract {
  generated_at: string;
  source_commit: string;
  epics: EpicRollup[];
}

// TODO(next-pm): fetch ProgressContract from the Oracle HTTP API via the
// oracle-studio proxy (GET /api/progress/<repo> or assembled client-side per
// the data-contract's "API surface" section), then render the board + rollup.
//
// export function ProgressPanel() {
//   const { data } = useOracle<ProgressContract>("/api/progress/mb-next-payment-gateway");
//   return ( /* 4-gate board + seal column + epic rollup */ );
// }

export type { ProgressContract, EpicRollup, StoryRow, Gate, GateState };
