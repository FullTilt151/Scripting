$CCMAgent = gwmi -Namespace root\sms\site_WP1 -Class SMS_SCI_ClientComp -ComputerName LOUAPPWPS1658 | where {$_.ClientComponentName -eq 'Configuration Management Agent'}
$CCMAgent.Get()
$props = $CCMAgent.Props

for ($i = 0; $i -lt $props.count; $i++) {
    if ($props[$i].PropertyName -eq "ScriptExecutionTimeout") {
        $props[$i].Value = 600
        break
    }
}

$CCMAgent.Props = $Props
$CCMAgent.Put()