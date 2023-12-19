#!/bin/bash

docker exec --user postgres -it snb-interactive-age bash -c "cd /var/lib/postgresql/; ./load_data_container.sh"
echo "DONE"