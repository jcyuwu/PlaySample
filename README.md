# PlayseeSample

一個類Instagram影片播放的範例程式碼

展示了三種視圖頁面

影片的collection view，影片與文字的table view，聲音與圖文的table view

<br/>

使用AVPlayerLayer實現於cell內的播放

在這些視圖頁面，會隨著滑動播放可見範圍內cell的影像與聲音

當cell滑出不可見後暫停cell的影像與聲音，再次滑入可見時恢復該cell的播放

點擊單一cell可以進入觀看放大的播放，也可滑動至下一個cell，或退回cell列表

反覆操作可以保持連貫的cell播放狀態

透過覆用cell與AVPlayer，實現像Instagram流暢的影片播放

前兩種視圖頁面使用線上影片來源位址

最後的視圖頁面使用bandcamp的open api取得音樂來源位址與封面圖片
