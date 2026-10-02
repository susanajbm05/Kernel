void kernel_main(void)
{
    volatile char* video = (volatile char*)0xB8000;
    const char* mensaje = "HOLI USUARIO";

    for (int i = 0; mensaje[i] != '\0'; i++)
    {
        video[i * 2] = mensaje[i];
        video[i * 2 + 1] = 0x0F;
    }

    while (1)
    {
        __asm__ volatile ("hlt");
    }
}