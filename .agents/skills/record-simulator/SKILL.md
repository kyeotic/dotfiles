---
name: record-simulator
description: Runs the current branch in the simulator and records a screencast
---

# record simulator

## Overview

Create a screen recording of the iOS or Android simulator (user specified) while exercising the changes or new features on the current branch. User may provide additional context.

## Workflow

### 1. Start the Dev Server

This can be done with the /start-local-nourish skill.
If that fails running

```
cd server
npm run dev
```

Will start the server, and

```
cd mobile-client
npm run ios # or npm run android
```

Will start the client. You can then use the simulator to interact with the app and record your screencast.
