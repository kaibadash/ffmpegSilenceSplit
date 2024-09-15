<!-- @format -->

# ffmpegSilenceSplit

`ffmpegSilenceSplit` is a Bash script that utilizes FFmpeg to automatically detect silent segments in an audio or video file and split the file accordingly. The script allows users to define the silence threshold and duration, making it flexible for various use cases such as removing pauses from podcasts, lectures, or other media files. By leveraging the power of FFmpeg's silencedetect filter, the script efficiently identifies and cuts out silent parts, simplifying the media editing process.

## How to use

```bash
 ./ffmpegSilenceSplit.sh your_audio.m4a
```

You can get `your_001.m4a` 〜 `your_nnn.m4a` .
