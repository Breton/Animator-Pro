#include "gfx.ih"

Errcode gl_shline(SHORT y,SHORT x0,SHORT x1, Sdat *sd)
{
	pj_set_hline(sd->rast,sd->color,x0,y,x1-x0+1);
	return(0);
}
