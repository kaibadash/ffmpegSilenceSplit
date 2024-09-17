<!-- @format -->

# ffmpegSilenceSplit

`ffmpegSilenceSplit` is a Bash script that utilizes FFmpeg to automatically detect silent segments in an audio or video file and split the file accordingly. The script allows users to define the silence threshold and duration, making it flexible for various use cases such as removing pauses from podcasts, lectures, or other media files. By leveraging the power of FFmpeg's silencedetect filter, the script efficiently identifies and cuts out silent parts, simplifying the media editing process.

## Setup

```bash
brew install grep # gnu grep for mac
brew install ffmpeg
```

## How to use

```bash
 ./ffmpegSilenceSplit.sh yours.m4a
```

You can get `yours_001.m4a` 〜 `yours_nnn.m4a` .

## Params

```bash
min_duration=30
silence_level="-30dB"
silence_duration_sec="0.5"
```
