try
	ingest_codar;
catch
	fprintf ( 1, 'FAILURE:  %s GMT (not EST):  ''%s''\n', datestr(now), lasterr ); 
end
quit
