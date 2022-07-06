from ubuntu:18.04

WORKDIR /home
COPY tcc_command.sh /home
RUN chmod +x ./tcc_command.sh
RUN ./tcc_command.sh -x -f ./