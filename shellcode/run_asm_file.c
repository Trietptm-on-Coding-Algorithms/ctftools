#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <stdlib.h>

#define NASM_COMMAND "nasm -o tmp_shell %s"
#define NASM_COMMAND2 "rm tmp_shell"

int main(int argc, char *argv[]){
  if(argc != 2)
  {
    fprintf(stderr, "Usage: %s <code.asm>\n", argv[0]);
    exit(1);
  }

  /* Create the .bin file */
  char *buf = (char*)malloc(strlen(argv[1]) + strlen(NASM_COMMAND));
  sprintf(buf, NASM_COMMAND, argv[1]);
  system(buf);

  /* Get the length */
  struct stat statbuf;
  if (stat(argv[1], &statbuf) == -1) {
    fprintf(stderr, "Assemble failed");
    exit(0);
  }

  /* Allocate some executable memory */
  void * a = mmap(0, statbuf.st_size, PROT_EXEC |PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_SHARED, -1, 0);
  printf("allocated %d bytes of executable memory at: %p\n", statbuf.st_size, a);

  /* Read the new file into the memory */
  FILE *file = fopen(argv[1], "rb");
  read(fileno(file), a, statbuf.st_size);

  /* Delete the file */
  system(NASM_COMMAND2);

  /* Run the code */
  ((void (*)(void)) a)();
}
