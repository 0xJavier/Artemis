.PHONY: setup build clean

setup:
	@echo "Setting up Artemis project config..."
	@if [ ! -f Config.xcconfig ]; then \
		echo "Creating Artemis.xcconfig from template..."; \
		cp Artemis.xcconfig.template Artemis.xcconfig; \
		echo ""; \
		echo "⚠️  Please edit Artemis.xcconfig and add your configuration values"; \
		echo "   - Set your Bundle ID with prefix (ex: com.organization)"; \
		echo "   - Add your Apple Developer Team ID"; \
		echo ""; \
	else \
		echo "Artemis.xcconfig already exists"; \
	fi
	@echo "Setup complete! You can now build the project."

build: setup
	xcodebuild -project Artemis.xcodeproj -scheme Artemis -configuration Debug

clean:
	xcodebuild clean -project Artemis.xcodeproj -scheme Artemis
	rm -rf build/
