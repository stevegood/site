+++
slug = "replace-linked-mp3-files-with-an-audio-player-using-jquery"
description = ""
author = "Steve Good"
date = 2009-09-30T17:00:00Z
title = "Replace Linked MP3 Files with an Audio Player Using jQuery"
draft = false

+++

A client of mine posts links to recorded audio files in a blog like structure.  Linking to the files doesn't really create a great user experience and I decided to swap out the links with an embedded flash player to allow for instant playback while still providing a way for users to download the files.

I chose the popular [WordPress Audio Player](http://wpaudioplayer.com/standalone) and jQuery to assist me with this.  The jQuery code is pretty straight forward.  I loop over all anchor tags that have an href value that ends in .mp3 and swap out the link with the flash player, dynamically pointing the player at the audio file on each pass.  The result is that I can create a unique audio player for each linked mp3 file very quickly.

```html
<script src="/js/audio-player.js" type="text/javascript"></script>
<script type="text/javascript">
$(document).ready(function(){
    $('a[href$=.mp3]').each(function(i){
        var audioPlayer = '<strong>' + $(this).html() + '</strong><br/>';
            audioPlayer += '<object type="application/x-shockwave-flash" data="/swf/player.swf" id="audioplayer' + i + '" height="24" width="290">';
            audioPlayer += '<param name="movie" value="/swf/player.swf">';
            audioPlayer += '<param name="FlashVars" value="playerID=' + i + '&amp;soundFile=' + $(this).attr('href') + '&titles=' + $(this).html() + '">';
            audioPlayer += '<param name="quality" value="high">';
            audioPlayer += '<param name="menu" value="false">';
            audioPlayer += '<param name="wmode" value="transparent">';
            audioPlayer += '</object>';
            audioPlayer += '<br/><a href=\"' + $(this).attr('href') + '\" target=\"_blank\">download mp3</a>';
        $(this).after(audioPlayer).remove();
    });
});
</script>
```
