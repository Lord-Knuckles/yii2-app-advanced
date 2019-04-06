<?php

$config = require __DIR__ . '/index-test-base.php';

$config['components']['db']['dsn'] = 'mysql:host=test-mysql-3;dbname=yii2advanced_test';

(new yii\web\Application($config))->run();