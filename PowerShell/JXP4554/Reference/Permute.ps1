function Permute ($list)
{
    $global:remove = { 
        param ($element, $list) 

        $newList = @() 
        $list | % { if ($_ -ne $element) { $newList += $_} }  

        return $newList 
    }

    $global:append = {
        param ($head, $tail)

        if ($tail.Count -eq 0)
            { return ,$head }

        $result =  @()

        $tail | %{
            $newList = ,$head
            $_ | %{ $newList += $_ }
            $result += ,$newList
        }

        return $result
    }

    if ($list.Count -eq 0)
        { return @() }

    $list | %{
        $permutations = Permute ($remove.Invoke($_, $list))
        return $append.Invoke($_, $permutations)
    }
}

cls

$list = 'a','b','c','d'

$permutations = Permute $list

$permutations | %{
    Write-Host ([string]::Join(", ", $_))
}