logtxt = fopen([AnyDir,'log.txt'],'a');
try
        %Whatever codes you need to run
        catch ME
            fprintf(logtxt, 'Error occurred at %s\n', datetime('now'));
            fprintf(logtxt, 'Error message: %s\n', ME.message);
            fprintf(logtxt, ['SearchName:  ' searchName]);
            fprintf(logtxt, 'Stack trace:\n');
            for k = 1:length(ME.stack)
                fprintf(logtxt, '  File: %s\n', ME.stack(k).file);
                fprintf(logtxt, '  Name: %s\n', ME.stack(k).name);
                fprintf(logtxt, '  Line: %d\n', ME.stack(k).line);
            end
            fprintf(logtxt, '\n'); % Add a newline for better readability
        end
     end
