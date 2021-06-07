<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/autoai-org/aid">
    <img src="assets/logo_transparent.png" alt="Logo" width="540">
  </a>

  <h3 align="center">A.I.D</h3>

  <p align="center">
    Aid your entire A.I activity.
    <br />
    <a href="https://aid.autoai.org"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://www.youtube.com/watch?v=0TU28hkx7KE">Video Demo</a>
    ·
    <a href="https://github.com/autoai-org/aid/issues">Report Bug</a>
    ·
    <a href="https://github.com/autoai-org/aid/issues">Request Feature</a>
  </p>
</p>

## Intro

AID is a DevOps System that is dedicated to machine learning. We will upload periodical releases in this repository. Stay tuned!

## Installation

You can install the software by running the following command in your terminal:

```
curl https://releases.autoai.org/aid/install.sh | bash -s
```

If you want the edge version, use the following command:

```
curl https://releases.autoai.org/aid/install.sh | bash -s -- edge
```

For the full installation guidelines (including the requirements of the system), please take a look at [installation](https://aid.autoai.org/docs/getting-started/installation).

### Stable Releases

The stable releases can be downloaded [here](https://github.com/eth-library-lab/aid-releases/releases).

### Edge Releases

Automatic builds will be uploaded to [Testing Repository](https://releases.autoai.org/aid/components/cmd/tui/). You can download the latest version there. The edge releases are not tested manually, and please be noted that

* These executable binaries are built for **x86_64** architecture only.
* The MacOS version may not work with Apple Silicon, even with Rosetta. There might be some issues with the Docker in the host.
* The Windows version, though provided, is still not recommended and is not a classic use case. We recommend to use the Windows Subsystems for Linux (WSL).

For more information about the releases, please take a look at the [documentation](https://aid.autoai.org/docs/pages/releases).