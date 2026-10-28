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

use OPNsense\Base\ApiMutableModelControllerBase;
use OPNsense\Core\Config;

/**
 * Class SettingsController
 * @package OPNsense\BeszelAgent
 */
class SettingsController extends ApiMutableModelControllerBase
{
    protected static $internalModelName = 'beszelagent';
    protected static $internalModelClass = 'OPNsense\BeszelAgent\BeszelAgent';

    /**
     * Retrieve current settings for general form
     * @return array
     */
    public function getAction()
    {
        $result = array();
        if ($this->request->isGet()) {
            $mdl = $this->getModel();
            $result['general'] = $mdl->general->getNodes();
        }
        return $result;
    }

    /**
     * Update settings from general form
     * @return array
     */
    public function setAction()
    {
        $result = array('result' => 'failed');
        if ($this->request->isPost() && $this->request->hasPost('general')) {
            $mdl = $this->getModel();
            $mdl->general->setNodes($this->request->getPost('general'));
            $valMsgs = $mdl->performValidation();
            foreach ($valMsgs as $field => $msg) {
                if (!isset($result['validations'])) {
                    $result['validations'] = array();
                }
                $result['validations']['general.' . $field] = $msg->getMessage();
            }
            if (empty($result['validations'])) {
                $mdl->serializeToConfig();
                Config::getInstance()->save();
                $result['result'] = 'saved';
            }
        }
        return $result;
    }
}
