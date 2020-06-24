<?php

///////////////////////////////////////////////////////
// Converts dbf file to CSV
//
// Dumps file to same location as dbf file. Basename is same.
//
// Based on:
// https://stackoverflow.com/a/41645054/2757825
// Date accessed: 28 April 2020
//
// Requires PHP extension dbase: 
// http://php.net/manual/en/book.dbase.php
//
// Parameters:
// 	$file	path and name of dbase file
//
// Usage:
//	php path/to/file/dbf_filename.dbf
///////////////////////////////////////////////////////

function dbfToCsv($file) {
    $path_parts = pathinfo($file);
    $csvFile = $path_parts['filename'] . '.csv';
    $output_path = $path_parts['dirname'];
    $output_path_file = $output_path . DIRECTORY_SEPARATOR . $csvFile;

    if (!$dbf = dbase_open( $file, 0 )) {
        return false;
    }

    $num_rec = dbase_numrecords( $dbf );

    $fp = fopen($output_path_file, 'w');
    for( $i = 1; $i <= $num_rec; $i++ ) {
        $row = dbase_get_record_with_names( $dbf, $i );
        if ($i == 1) {
            //print header
            if ( ! fputcsv($fp, array_keys($row) ) ) {
            	die("ERROR: row insert failed!\n");
            }
        }
        fputcsv($fp, $row);
    }
    fclose($fp);
}

if ($argc > 1) {
  if ( file_exists( $argv[1] ) ) {
    $thefile = $argv[1];
    dbfToCsv( $thefile );
  } else {
  	echo "ERROR: '$argv[1]': invalid file or path ($argv[0])\n";
  }
} else {
  echo "ERROR: missing file argument ($argv[0])\n";
}

?>