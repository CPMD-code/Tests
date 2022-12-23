C     example program to create a grid file for use as
c     an external potential input in cpmd calculations.
C     this (simple) example assumes an orthorhombic cell 
C     and produces a linear potential in z-direction.
C
C     feel free to adapt for your own purposes.
C     you have to make sure, that the grid used here
C     matches the real space grid of your cpmd run.
C     
C     all parameters are in a.u.
C
C     it is advisable to compile (and run) this program with 
C     the same flags and on the same platform as your cpmd binary.
C     otherwise the binary grid data may be incompatible.
C     
C     01/2004 <axel.kohlmeyer@theochem.ruhr-uni-bochum.de>
C     
      program mkextpot
      implicit none
      integer nn(3)
      real*8 phi,origin(3),cell(3),delta(3), x, y
      integer i,j,k
      external phi
      
      print*, 'give cell [a, b, c] (in bohr)'
      read*,(cell(i),i=1,3)

      print*, 'give origin [x0,y0,z0] (in bohr)'
      read*,(origin(i),i=1,3)

      print*, 'give mesh [na,nb,nc]'
      read*,(nn(i),i=1,3)

      do i=1,3
        delta(i) = cell(i)/dble(nn(i))
      end do

      print*,' '
      print*,'input parameters:'
      print*,'cell  :   ', (cell(i),i=1,3)
      print*,'origin:   ', (origin(i),i=1,3)
      print*,'mesh:     ', (nn(i),i=1,3)
      print*,'dx,dy,dz: ', (delta(i),i=1,3)
      print*,' '
      print*,'writing extpot.unfo.grid...'

      open(99,file='extpot.unfo.grid',
     $     form='unformatted',status='unknown')

      do i=1,nn(1)
        x=dble(i-1)*delta(1)+origin(1)
        do j=1,nn(2)
          y=dble(j-1)*delta(2)+origin(2)
          write(99) (phi(x,y,dble(k-1)*delta(3)+origin(3)),k=1,nn(3))
        enddo
      enddo
      close(99)

      stop 'external potential grid written'
      end


c     potential function
      real*8 function phi(x,y,z)
      real*8 x,y,z

      phi = 0.01*z

      return
      end
