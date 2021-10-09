---
title: Processing Flow
keywords: tau execution flow
tags: [tau]
summary: "Processing Flow"
permalink: processing_flow.html
---

# The processing flow

{% include image.html file="processing_flow.svg"  caption="The processing flow when play()" %}


Almost all the API verbs in `TauPlayer` and `TauRecorder`, follow the same schema.

There is a completer define for each verb. 
This is the Future associated with this completer which is returned to the App caller, and that the App await.

The instruction is blocked between the calling and the reception of the Future.
More, a semaphore is got during all this time so that the App can never be running two verbs at the same time.

But the elapse time is very short. There is almost no processing before the app receive its Future.
Of course it is really important that the call done to the OS (mediaPlayer.prepare() during the execution of play()) does not block.

When the low level module knows that everything is completed (reception of the callback `onPrepareListener),
then the Completer is completed and the App returns from its await.

The elapse time between the beginning of the await and the end of the await can be long. Even very long.
