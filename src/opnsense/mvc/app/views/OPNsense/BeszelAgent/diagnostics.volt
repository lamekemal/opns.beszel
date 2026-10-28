{#
    Copyright (C) 2024 Beszel Agent Plugin
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
       this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#}

<script>
    $(document).ready(function () {
        var logLinesDefault = 500;

        // Fetch and display log content
        function fetchLogs(numberOfLines) {
            var lines = numberOfLines || logLinesDefault;
            $("#logContent").html("{{ lang._('Loading...') }}");
            ajaxGet(url = '/api/beszelagent/service/log/' + lines, sendData = {}, callback = function (data, status) {
                if (data && data['response']) {
                    var logText = data['response'];
                    // Escape HTML and display
                    var escaped = $('<div/>').text(logText).html();
                    $("#logContent").html('<pre class="log-pre">' + escaped + '</pre>');
                    // Auto-scroll to bottom
                    var logContainer = document.getElementById('logContainer');
                    if (logContainer) {
                        logContainer.scrollTop = logContainer.scrollHeight;
                    }
                } else {
                    $("#logContent").html('<p class="text-muted">{{ lang._("No log data available.") }}</p>');
                }
            });
        }

        // Refresh button
        $("#refreshLogs").click(function () {
            var lines = $("#logLines").val() || logLinesDefault;
            fetchLogs(lines);
        });

        // Clear display
        $("#clearLogs").click(function () {
            $("#logContent").html('<p class="text-muted">{{ lang._("Log display cleared.") }}</p>');
        });

        // Load logs on page load
        fetchLogs(logLinesDefault);
    });
</script>

<style>
    .log-pre {
        background-color: #1a1a2e;
        color: #00ff88;
        padding: 15px;
        border-radius: 6px;
        font-family: 'Courier New', Courier, monospace;
        font-size: 12px;
        line-height: 1.5;
        white-space: pre-wrap;
        word-wrap: break-word;
        max-height: none;
        overflow: visible;
    }
</style>

<div class="content-box" style="padding: 10px;">
    <div class="col-md-12">
        <h1><i class="fa fa-file-text-o"></i> {{ lang._('Beszel Agent Log') }}</h1>
        <p>{{ lang._('View the Beszel Agent service log to monitor connections and diagnose issues.') }}</p>
    </div>
</div>

<ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
    <li class="active"><a data-toggle="tab" href="#logs">{{ lang._('Service Log') }}</a></li>
</ul>

<div class="tab-content content-box">
    <div id="logs" class="tab-pane fade in active">
        <div class="col-md-12" style="padding-top: 15px;">
            <div class="row">
                <div class="col-md-3">
                    <div class="input-group">
                        <span class="input-group-addon">{{ lang._('Lines') }}</span>
                        <input type="number" class="form-control" id="logLines" value="500" min="10" max="10000" step="100"/>
                    </div>
                </div>
                <div class="col-md-9">
                    <button class="btn btn-primary" id="refreshLogs" type="button">
                        <i class="fa fa-refresh"></i> {{ lang._('Refresh') }}
                    </button>
                    <button class="btn btn-default" id="clearLogs" type="button">
                        <i class="fa fa-eraser"></i> {{ lang._('Clear Display') }}
                    </button>
                </div>
            </div>
        </div>

        <div class="col-md-12" style="padding-top: 15px;">
            <div id="logContainer" style="max-height: 600px; overflow-y: auto; border: 1px solid #333; border-radius: 6px;">
                <div id="logContent">
                    <p class="text-muted">{{ lang._('Loading...') }}</p>
                </div>
            </div>
        </div>
    </div>
</div>
