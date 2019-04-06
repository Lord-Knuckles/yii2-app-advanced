<?php
require_once 'vendor/autoload.php';

/**
 * This is project's console commands configuration for Robo task runner.
 *
 * @see http://robo.li/
 */
class RoboFile extends \Robo\Tasks
{
    use \Codeception\Task\MergeReports;
    use \Codeception\Task\SplitTestsByGroups;

    protected $rootPaths = ['common', 'frontend', 'backend'];
    // protected $rootPaths = ['backend'];

    protected $groups = 4;

    public function parallelSplitTests($rootPath)
    {
        $this->taskSplitTestFilesByGroups($this->groups)
        ->projectRoot($rootPath)
        ->testsFrom('.')
        ->groupsTo($rootPath.'/tests/_data/parallel-files/paracept_')
        ->run();
    }

    public function parallelRun($rootPath)   {
        
        $parallel = $this->taskParallelExec();
            for ($i = 1; $i <= $this->groups; $i++) {            
            
                    $parallel->process(
                        $this->taskCodecept()                        
                            ->configFile($rootPath)
                            ->env("env$i")
                            // ->debug(true)
                            ->group("paracept_$i") // run for groups p*
                            ->html("result_paracept_{$rootPath}_$i.html") // provide html report
                    );
            }
        
        return $parallel
        // ->printed(true)
        ->run();
    }

    public function parallelMergeResults()
    {
        
        foreach($this->rootPaths as $path){
            $merge = $this->taskMergeHtmlReports();
            for ($i=1; $i <= $this->groups; $i++) {      

                $merge->from("$path/tests/_output/result_paracept_{$path}_$i.html");
            }
            $merge->into("test-results/result_paracept_{$path}.html")->run();
        }
        
    }

    function parallelAll()
    {
        $time_pre = microtime(true);     

        echo PHP_EOL .'Starting tests for: '. PHP_EOL . var_export($this->rootPaths, true) . PHP_EOL;

        foreach($this->rootPaths as $path){
            $this->parallelSplitTests($path);
        }

        $result = 0;
        foreach($this->rootPaths as $path){
           $result &= $this->parallelRun($path)->getExitCode();
        }

        $this->parallelMergeResults();

        $time_post = microtime(true);

        $exec_time = $time_post - $time_pre;

        echo PHP_EOL .'>>>>>> Tests were finished after ' . $exec_time . ' seconds <<<<<<' . PHP_EOL;
        return $result;
    }
}