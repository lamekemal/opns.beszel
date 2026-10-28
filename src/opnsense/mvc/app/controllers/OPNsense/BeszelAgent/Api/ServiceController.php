<?php

/**
 *    Copyright (C) 2024 Beszel Agent Plugin
 *    All rights reserved.
 *
 *    Redistribution and use in source and binary forms, with or without
 *    modification, are permitted provided that the following conditions are met:
 *
 *    1. Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *
 *    2. Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 *    THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 *    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 */

namespace OPNsense\BeszelAgent\Api;

use OPNsense\Base\ApiControllerBase;
use OPNsense\Core\Backend;

/**
 * Class ServiceController
 * @package OPNsense\BeszelAgent
 */
class ServiceController extends ApiControllerBase
{
    /**
     * Start beszel-agent service
     * @return array
     */
    public function startAction()
    {
        if ($this->request->isPost()) {
            $backend = new Backend();
            $response = $backend->configdRun('beszelagent start');
            return array('response' => $response);
        }
        return array('response' => array());
    }

    /**
     * Stop beszel-agent service
     * @return array
     */
    public function stopAction()
    {
        if ($this->request->isPost()) {
            $backend = new Backend();
            $response = $backend->configdRun('beszelagent stop');
            return array('response' => $response);
        }
        return array('response' => array());
    }

    /**
     * Restart beszel-agent service
     * @return array
     */
    public function restartAction()
    {
        if ($this->request->isPost()) {
            $backend = new Backend();
            $response = $backend->configdRun('beszelagent restart');
            return array('response' => $response);
        }
        return array('response' => array());
    }

    /**
     * Retrieve status of beszel-agent service
     * Returns standard 'status' string ('running' or 'stopped') for UI service control
     * @return array
     */
    public function statusAction()
    {
        $backend = new Backend();
        $response = trim((string)$backend->configdRun('beszelagent status'));
        $status = 'stopped';
        if (strpos($response, 'is running') !== false) {
            $status = 'running';
        }
        return array('status' => $status, 'response' => $response);
    }

    /**
     * Reconfigure beszel-agent service
     * Regenerates config from template and restarts the service if enabled
     * @return array
     */
    public function reconfigureAction()
    {
        if ($this->request->isPost()) {
            $backend = new Backend();
            $backend->configdRun('template reload OPNsense/BeszelAgent');
            $response = $backend->configdRun('beszelagent reconfigure');
            return array('response' => $response);
        }
        return array('response' => array());
    }

    /**
     * Retrieve log file content
     * @param int $lines number of lines to fetch
     * @return array
     */
    public function logAction($lines = 500)
    {
        $backend = new Backend();
        $response = $backend->configdpRun('beszelagent log', array((string)intval($lines)));
        return array('response' => $response);
    }
}
