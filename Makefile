FORT = gfortran
CC = gcc
#OPTS = -O3 -ffast-math -funroll-loops -fstrict-aliasing -cpp -Wunused
#OPTS = -O3 -march=native -ffast-math -fstrict-aliasing -cpp -Wunused
OPTS = -march=native -ffast-math -fstrict-aliasing -g -Ofast -Wunused -cpp -fPIC -static-libgfortran -fopenmp

#BLASINC = -I/opt/OpenBLAS/include
#BLASLIB = -L/opt/OpenBLAS/lib/ -lopenblas

#BLASINC = -I/usr/include/atlas/
#BLASLIB = -L/usr/lib/atlas-base/ -lcblas

MKLROOT = /opt/intel/mkl
BLASINC = -m64 -I${MKLROOT}/include -Dmkl
BLASLIB = -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_lp64.a \
          ${MKLROOT}/lib/intel64/libmkl_core.a ${MKLROOT}/lib/intel64/libmkl_sequential.a \
          -Wl,--end-group -lpthread -lm -ldl

SRCDIR = ./src
OBJDIR = $(SRCDIR)/obj
BINDIR = ./test
LIBDIR = ./lib

LIBFILE = $(LIBDIR)/libemdee.a

OBJ = $(OBJDIR)/EmDee.o $(OBJDIR)/mEmDee.o

.PHONY: all test lib testc testfortran

all: test

clean:
	rm -rf $(OBJDIR)
	rm -rf $(LIBDIR)
	rm -f $(BINDIR)/testfortran $(BINDIR)/testc

test: testfortran testc

testc: $(BINDIR)/testc

testfortran: $(BINDIR)/testfortran

lib: $(LIBFILE)

$(BINDIR)/testfortran: $(OBJDIR)/testfortran.o
	mkdir -p $(BINDIR)
	$(FORT) $(OPTS) -o $@ -J$(LIBDIR) $< $(OBJDIR)/mRandom.o -L$(LIBDIR) -lemdee $(BLASLIB)

$(OBJDIR)/testfortran.o: $(SRCDIR)/testfortran.f90 $(OBJDIR)/mRandom.o $(LIBFILE)
	$(FORT) $(OPTS) -c -o $@ -J$(LIBDIR) $<

$(BINDIR)/testc: $(OBJDIR)/testc.o
	mkdir -p $(BINDIR)
	$(CC) $(OPTS) -fwhole-program -o $@ $< -L$(LIBDIR) -lemdee $(BLASLIB) -lgfortran

$(OBJDIR)/testc.o: $(SRCDIR)/testc.c $(LIBFILE)
	$(CC) $(OPTS) -c -o $@ $<

$(LIBFILE): $(OBJ)
	ar -cr $(LIBFILE) $(OBJ)

$(OBJDIR)/mRandom.o: $(SRCDIR)/mRandom.f90
	mkdir -p $(OBJDIR)
	mkdir -p $(LIBDIR)
	$(FORT) $(OPTS) -c -o $@ $< -J$(LIBDIR)

$(OBJDIR)/mEmDee.o: $(SRCDIR)/mEmDee.f90
	mkdir -p $(LIBDIR)
	$(FORT) $(OPTS) -c -o $@ $< -J$(LIBDIR)

$(OBJDIR)/EmDee.o: $(SRCDIR)/EmDee.c $(SRCDIR)/EmDee.h
	mkdir -p $(OBJDIR)
	$(CC) $(OPTS) -c -o $@ $< $(BLASINC)

