<?php 

$config = require (dirname(__DIR__, 3) . '/config/codeception-local.php');
$config['components']['db']['dsn'] = 'mysql:host=test-mysql;dbname=yii2advanced_test';

return $config;

