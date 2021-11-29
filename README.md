# AstroSolution

This is the source-code for the WebApp hosted at [https://paloz.marum.de/AstroComputation/index.html].

![image info](./Docs/AstroSolutionScreenshot.png)

This package implements the integration of orbital (astronomical) solutions
for Earth, based on the original implementation by [Laskar et al. (1993)](https://cdsarc.u-strasbg.fr/viz-bin/ftp-index?/ftp/cats/vi/63)
(retrieved 29 Nov 2021). In particular, it makes use of Keplerian elements, 
and calculates Earth's obliquity and climatic precession using Dopri8 and Adams
integration methods. The calculation is performed by the client's machine by 
compiling the code as Wasm, using [SwiftWasm](https://swiftwasm.org), and 
the [TokamakUI](https://github.com/TokamakUI/Tokamak) project to provide a 
SwiftUI like declarative Webpage definition.

Orbital elements were published for the solutions of:
- Laskar, J., Joutel, F., Boudin, F.: 1993, Orbital, precessional and insolation 
quantities for the Earth from -20 Myr to + 10Myr, Astron. Astrophys. 270, 522 
[PDF](http://adsabs.harvard.edu/cgi-bin/nph-data_query?bibcode=1993A%26A...270..522L&link_type=ARTICLE&db_key=AST&high=).
- Laskar, J., Fienga, A., Gastineau, M., Manche, H.: 2011,
La2010: A new orbital solution for the long-term motion of the Earth.
Astron. Astrophys., Volume 532, A89, [PDF](http://www.aanda.org/articles/aa/pdf/2011/08/aa16836-11.pdf).
Datafiles for the solutions La2010a,b,c,d are available here: [http://vo.imcce.fr/insola/earth/online/earth/La2010/index.html].

*IMPORTANT*: Note that the reference frame for the La2010a,b,c,d solutions differs 
from those of La1993, and need to be rotated into the correct reference frame 
(done by the Webapp provided here.)

The following two orbital (Keplerian) elements were made available by the author
(thank you!). They are not included in the supplementary materials or the 
[homepage](https://www.soest.hawaii.edu/oceanography/faculty/zeebe_files/Astro.html)
The citations to them are: 
- Zeebe, R. E. Numerical Solutions for the orbital motion of the Solar System over the Past 100 Myr: Limits and new results. The Astronomical Journal, 2017. [PDF](https://www.soest.hawaii.edu/oceanography/faculty/zeebe_files/Publications/ZeebeAJ17P.pdf)
- Zeebe, R. E. and Lourens, L. J. Solar system chaos and the Paleocene-Eocene boundary age constrained by geology and astronomy. Science, [10.1126/science.aax0612], 2019.
  (PDF)[https://www.soest.hawaii.edu/oceanography/faculty/zeebe_files/Publications/ZeebeLourens19.pdf] (Supplement)[https://www.soest.hawaii.edu/oceanography/faculty/zeebe_files/Publications/ZeebeLourens19SM.pdf]

*IMPORTANT*: Note that the reference frame for the ZB2017e and ZB2018a solutions differs 
from those of La1993, and need to be rotated into the correct reference frame 
(done by the WebApp provided here.)

For the solution La2004 no orbital elements were published openly, nor made 
available by request to the author, so no further computation 
of different tidal dissipation and dynamical ellipticity models is possible here.
A&A 428, 261-285 (2004), DOI: 10.1051/0004-6361:20041335
Laskar, J., Robutel, P., Joutel, F., Gastineau, M., Correia, A.C.M., Levrard, B.: 2004,
A long term numerical solution for the insolation quantities of the Earth. 

Likewise, for the orbital solution La2011, referenced as 
(Strong chaos induced by close encounters with Ceres and Vesta”, by J. Laskar, M. Gastineau, J.-B. Delisle, A. Farrès, and A. Fienga. Astronomy & Astrophysics, 2011, vol. 532, L4.)[https://dx.doi.org/10.1051/0004-6361/201117504], 
 no data were formally published, but can be accessed via (Astrochron)[http://www.geology.wisc.edu/~smeyers/astrochron/la11.txt.bz2]. 
 Both solutions can thus unfortunately not be
 used for additional reproducible research.

Heiko Pälike, 29. November 2021

