#include <stdio.h>
#include <dlfcn.h>

// we need dlfcn.h for dlopen, dlsym, dlclose , its in linux , so well i aint gon worrk on windows ig
//this allows for loding sared libs at runtime instaed pf compileetime

int main() {

    char opname[10];
    int num1, num2;
    

    while (scanf("%s %d %d", opname, &num1, &num2) == 3) {
        //krrp reading in this format ie till were getting args in this format ie till eof

        char libpath[50];
        snprintf(libpath, sizeof(libpath), "./lib%s.so", opname);
        //snprinntf is used to format the str in buffer
        // we shall bulid the name of lib using func name , ie lib+func+.so

        void *libhandle = dlopen(libpath, RTLD_LAZY);
        // load the shared library into memory at runtime
        // RTLD_LAZY lowk mesnas that only look when sm symbol or wwhatevis called , only them jump to resolve it

        if (!libhandle) {
            //not found or sm other issue , ie pointer to null ie lib not htere
            fprintf(stderr, "error loading library: %s\n", dlerror());
            return 1;
            // this would happen if the .so file dont exist
        }

        typedef int (*op_func)(int, int);
        op_func dofunc = (op_func) dlsym(libhandle, opname);
        // get a pointer to the function named <op> inside the library
        // e.g. for "add", we look for a function called "add" in libadd.so

        if (!dofunc) {
            fprintf(stderr, "error finding function: %s\n", dlerror());
            dlclose(libhandle);
            return 1;
        }
        // if dlsym fails, the function name doesn't exist in the library
        //close handle 

        int answer = dofunc(num1, num2);
        printf("%d\n", answer);

        // call the func through ptr

        dlclose(libhandle);
        // we can only have one .so loaded at a time , cuz mem constraints
    }

    return 0;
}