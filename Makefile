install: 
	gem install clamp
	gem install aws-sdk
	cp s3_versioning.rb /usr/bin/s3_versioning
	chmod +x /usr/bin/s3_versioning
uninstall:
	rm /usr/bin/s3_versioning
