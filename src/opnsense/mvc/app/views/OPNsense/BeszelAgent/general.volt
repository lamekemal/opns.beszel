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
        var data_get_map = {'frm_general_settings': '/api/beszelagent/settings/get'};
        mapDataToFormUI(data_get_map).done(function (data) {
            formatTokenizersUI();
            $('.selectpicker').selectpicker('refresh');
        });

        // Update service status on page load
        updateServiceStatusUI('beszelagent');

        // Save settings
        $("#saveAct").click(function () {
            saveFormToEndpoint(url = '/api/beszelagent/settings/set', formid = 'frm_general_settings', callback_ok = function () {
                $("#saveAct_progress").addClass("fa fa-spinner fa-pulse");
                ajaxCall(url = '/api/beszelagent/service/reconfigure', sendData = {}, callback = function (data, status) {
                    updateServiceStatusUI('beszelagent');
                    $("#saveAct_progress").removeClass("fa fa-spinner fa-pulse");
                });
            });
        });

        // Test connection / status
        $("#testAct").click(function () {
            $("#testAct_progress").addClass("fa fa-spinner fa-pulse");
            ajaxCall(url = '/api/beszelagent/service/status', sendData = {}, callback = function (data, status) {
                $("#testAct_progress").removeClass("fa fa-spinner fa-pulse");
                if (data['response']) {
                    BootstrapDialog.show({
                        type: BootstrapDialog.TYPE_INFO,
                        title: "{{ lang._('Beszel Agent Status') }}",
                        message: data['response'],
                        draggable: true
                    });
                }
            });
        });
    });
</script>

<div class="content-box" style="padding: 10px;">
    <div class="col-md-12">
        <h1><i class="fa fa-heartbeat"></i> {{ lang._('Beszel Agent') }}</h1>
        <p>{{ lang._('Configure Beszel Agent to connect to your Beszel Hub monitoring server.') }}</p>
    </div>
</div>

<ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
    <li class="active"><a data-toggle="tab" href="#settings">{{ lang._('Settings') }}</a></li>
</ul>

<div class="tab-content content-box">
    <div id="settings" class="tab-pane fade in active">
        {{ partial("layout_partials/base_form",['fields':generalForm,'id':'frm_general_settings'])}}

        <div class="col-md-12">
            <hr/>
            <button class="btn btn-primary" id="saveAct" type="button">
                <b>{{ lang._('Save') }}</b> <i id="saveAct_progress"></i>
            </button>
            <button class="btn btn-default" id="testAct" type="button">
                <b>{{ lang._('Test / Status') }}</b> <i id="testAct_progress"></i>
            </button>
        </div>
    </div>
</div>
