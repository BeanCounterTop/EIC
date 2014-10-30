if not exist c:\deploy (
	mkdir c:\deploy
	)
xcopy . c:\deploy /e /d /y

