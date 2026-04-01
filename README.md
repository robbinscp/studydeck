# StudyDeck

A self-hosted, browser-based flashcard and quiz tool built around PDF study materials. Upload exam PDFs, key the correct answers, and drill questions in a randomized quiz mode — all stored locally in the browser, no backend required.

## How it works

StudyDeck is a single HTML file (`study-tool-v2.html`) served by nginx. All state — exams, questions, and answer keys — lives in the browser via `window.storage`. There is no database and no server-side logic.

**Core workflow:**
1. Create an exam (e.g. "CDAE Exam A")
2. Upload one or more PDFs — questions are extracted automatically via PDF.js
3. Key correct answers in the Answers tab (A/B/C/D per question)
4. Hit Start Quiz to drill — the tool tracks correct, missed, and remaining counts per session

**Answer editor features:**
- Full question text with stacked, readable answer options
- Filter by missing answers / has answer
- Search across question text and source filename
- CSV export/import for bulk answer keying

## Running locally

```bash
docker pull ghcr.io/<your-org>/studydeck:latest
docker run -p 8080:80 ghcr.io/<your-org>/studydeck:latest
```

Then open `http://localhost:8080`.

## Building from source

```bash
docker build -t studydeck .
docker run -p 8080:80 studydeck
```

## CI/CD

Pushes to `main` trigger a two-job GitHub Actions pipeline:

**`build-and-push`** — builds the Docker image and pushes two tags to GHCR:
- `latest` — always points to the current main
- `sha-<commit>` — immutable reference for rollbacks

**`scan`** — runs after the push using [Grype](https://github.com/anchore/grype) (Anchore) to scan the pushed image for CVEs. Fails the workflow on `CRITICAL` severity findings. Results are uploaded to the repo's Security → Code scanning tab in SARIF format. The Grype vulnerability DB is cached daily to keep scan times fast.

### Why Grype and not Trivy?

Trivy suffered a significant supply chain compromise in March 2026 where attackers hijacked 76 of 77 release tags in `trivy-action` and published malicious binaries that stole CI secrets. Grype is a functionally equivalent alternative with no known incidents. See the [CrowdStrike writeup](https://www.crowdstrike.com/en-us/blog/from-scanner-to-stealer-inside-the-trivy-action-supply-chain-compromise/) for full details.

## Security notes

- The base image (`nginx:alpine`) runs `apk upgrade` at build time to pull in the latest Alpine package patches before Grype scans it
- `GITHUB_TOKEN` is scoped to `packages: write` only for the build job; the scan job uses `packages: read`
- No secrets are required beyond the automatically-provided `GITHUB_TOKEN`
