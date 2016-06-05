# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Programa de tutorias del Dep de orientación y psicología del Instituto Tecnológico de Costa Rica.
# Sede Interuniversitaria de Alajuela.
# Ejemplo de Makefile
# Hecho por José Rodolfo Godínez
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Para usar este Makefile sólo basta con cambiar la variable NAME por el nombre del archivo que desee

NAME= Progra2
CC= nasm

all: $(NAME).o
	gcc -m32 -o $(NAME) $(NAME).o

		# ld ~ GNU Linker
		# -m ~ emulador
		# elf_i386 ~ arquitectura (32 bits)
		# -o ~ nombrar salida

$(NAME).o: $(NAME).asm
	$(CC) -f elf -g -F stabs $(NAME).asm -l $(NAME).lst

		# nasm ~ compilador
		# -f ~ formato del archivo de salida
		# elf ~ arquitectura (64)
		# -g ~ símbolos para debugger
		# -F ~ formato de los símbolos
		# -l ~ crea un archivo .lst

.PHONY clean:
	rm $(NAME).lst
	rm $(NAME).o

	# rm ~ comando para borrar un archivo
