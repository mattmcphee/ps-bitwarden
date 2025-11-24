function Get-DeletionDate {
    $getDate = Get-Date
    $date = $getDate.AddDays(14).ToString("yyyy-MM-dd")
    $time = $getDate.ToString("HH:mm:ss.fff")
    $deletionDate = "$($date)T$($time)Z" #needs to have T and Z
    
    return $deletionDate
}
