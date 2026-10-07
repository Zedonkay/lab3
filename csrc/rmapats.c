// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  schedNewEvent (struct dummyq_struct * I1509, EBLK  * I1207, U  I624);
void  schedNewEvent (struct dummyq_struct * I1509, EBLK  * I1207, U  I624)
{
    U  I1823;
    U  I1824;
    U  I1825;
    struct futq * I1826;
    struct dummyq_struct * pQ = I1509;
    I1823 = ((U )vcs_clocks) + I624;
    I1825 = I1823 & ((1 << fHashTableSize) - 1);
    I1207->I670 = (EBLK  *)(-1);
    I1207->I671 = I1823;
    if (0 && rmaProfEvtProp) {
        vcs_simpSetEBlkEvtID((EBLK  *)I1207);
    }
    if (I1823 < (U )vcs_clocks) {
        I1824 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1207, I1824 + 1, I1823);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I624 == 1)) {
        I1207->I673 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I670 = I1207;
        peblkFutQ1Tail = I1207;
    }
    else if ((I1826 = pQ->I1408[I1825].I696)) {
        I1207->I673 = (struct eblk *)I1826->I694;
        I1826->I694->I670 = (RP )I1207;
        I1826->I694 = (RmaEblk  *)I1207;
    }
    else {
        sched_hsopt(pQ, I1207, I1823);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
