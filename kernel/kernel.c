void kernel_main(void)
{
volatile char* video = (volatile char*)0xB8000;
const char mensaje = "HOLI USUARIO";
3
for (int 1 = 0; mensaje[i] !='\0'; i++)
{

video[i * 2] = mensaje[i];
video[i * 2 + 1] = 0xoF;

}

while (1)
{
     _asm_ volatile ("hlt");

}

}
