#!/usr/bin/env bash

export DB_URL="mongodb://$($DB_USER):$(DB_PASS)@$(DB_URI)::27017/"

npm start