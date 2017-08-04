#!/bin/bash
set -x

timeout 30s bundle exec htmlproofer _site --only-4xx --external_only --check-html --check-favicon