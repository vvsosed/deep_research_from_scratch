SHELL := /bin/bash

# Makefile for managing the LangGraph dev server.
#
# Usage:
#   make start   # start langgraph dev in the background
#   make stop    # stop the running langgraph dev server
#   make restart # restart the server
#   make status  # check whether the server is running
#   make logs    # tail the server log file
#   make run     # run langgraph dev in the foreground

PYTHON_VERSION ?= 3.13
HOST ?= 127.0.0.1
PORT ?= 2024
START_TIMEOUT ?= 60

LANGGRAPH_CMD := uvx --refresh \
	--from "langgraph-cli[inmem]" \
	--with-editable . \
	--python $(PYTHON_VERSION) \
	langgraph dev \
	--host $(HOST) \
	--port $(PORT) \
	--allow-blocking

RUNTIME_DIR := .langgraph_api
PID_FILE := $(RUNTIME_DIR)/dev.pid
LOG_FILE := $(RUNTIME_DIR)/dev.log

.PHONY: start stop restart status logs run help

help:
	@echo "Available targets:"
	@echo "  make start    - Start langgraph dev server in the background"
	@echo "  make stop     - Stop the running langgraph dev server"
	@echo "  make restart  - Restart the langgraph dev server"
	@echo "  make status   - Show whether the server is running"
	@echo "  make logs     - Tail the langgraph dev server log"
	@echo "  make run      - Run langgraph dev server in the foreground"
	@echo ""
	@echo "Configuration (override on the command line):"
	@echo "  PYTHON_VERSION=$(PYTHON_VERSION)"
	@echo "  HOST=$(HOST)"
	@echo "  PORT=$(PORT)"

start:
	@set -e; \
	if [ -f $(PID_FILE) ] && kill -0 $$(cat $(PID_FILE)) 2>/dev/null; then \
		echo "langgraph dev is already running (pid $$(cat $(PID_FILE)))."; \
		exit 0; \
	fi; \
	echo "Starting langgraph dev on http://$(HOST):$(PORT) ..."; \
	mkdir -p $(RUNTIME_DIR); \
	nohup $(LANGGRAPH_CMD) > $(LOG_FILE) 2>&1 & \
	PID=$$!; \
	echo $$PID > $(PID_FILE); \
	for i in $$(seq 1 $(START_TIMEOUT)); do \
		if ! kill -0 $$PID 2>/dev/null; then \
			echo "Process $$PID exited before becoming ready. Last log lines (watchfiles noise filtered):"; \
			grep -av 'watchfiles.main' $(LOG_FILE) | tail -n 40 || true; \
			rm -f $(PID_FILE); \
			exit 1; \
		fi; \
		if (echo > /dev/tcp/$(HOST)/$(PORT)) >/dev/null 2>&1; then \
			echo "Started (pid $$PID). Listening on http://$(HOST):$(PORT). Logs: $(LOG_FILE)"; \
			exit 0; \
		fi; \
		sleep 1; \
	done; \
	echo "Server did not become reachable on http://$(HOST):$(PORT) within $(START_TIMEOUT)s."; \
	echo "Stopping process $$PID."; \
	kill $$PID 2>/dev/null || true; \
	for i in 1 2 3 4 5; do \
		if kill -0 $$PID 2>/dev/null; then sleep 1; else break; fi; \
	done; \
	kill -9 $$PID 2>/dev/null || true; \
	rm -f $(PID_FILE); \
	echo "Last log lines (watchfiles noise filtered):"; \
	grep -av 'watchfiles.main' $(LOG_FILE) | tail -n 40 || true; \
	exit 1

stop:
	@if [ ! -f $(PID_FILE) ]; then \
		echo "No pid file found ($(PID_FILE)); langgraph dev is not running."; \
		exit 0; \
	fi
	@PID=$$(cat $(PID_FILE)); \
	if kill -0 $$PID 2>/dev/null; then \
		echo "Stopping langgraph dev (pid $$PID) ..."; \
		kill $$PID; \
		for i in 1 2 3 4 5 6 7 8 9 10; do \
			if kill -0 $$PID 2>/dev/null; then sleep 1; else break; fi; \
		done; \
		if kill -0 $$PID 2>/dev/null; then \
			echo "Process $$PID did not exit; sending SIGKILL."; \
			kill -9 $$PID 2>/dev/null || true; \
		fi; \
		echo "Stopped."; \
	else \
		echo "No process running with pid $$PID."; \
	fi; \
	rm -f $(PID_FILE)

restart: stop start

status:
	@if [ -f $(PID_FILE) ] && kill -0 $$(cat $(PID_FILE)) 2>/dev/null; then \
		echo "langgraph dev is running (pid $$(cat $(PID_FILE))) on http://$(HOST):$(PORT)."; \
	else \
		echo "langgraph dev is not running."; \
		[ -f $(PID_FILE) ] && rm -f $(PID_FILE) || true; \
	fi

logs:
	@if [ ! -f $(LOG_FILE) ]; then \
		echo "No log file found ($(LOG_FILE))."; \
		exit 0; \
	fi
	@tail -f $(LOG_FILE)

run:
	$(LANGGRAPH_CMD)
