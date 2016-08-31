function [] = WriteLegend(ax2,num_over,num_under,num_mito,num_nuc,num_apo,num_newborn)
axes(ax2)
cla
foo = linspace(.6,.1,16);
text(0,foo(1),'Key:','fontweight','b','fontsize',18)
text(0,foo(2),'n = Nucleus','color','c','fontweight','b','fontsize',18)
text(0,foo(3),'m = Mitotic Cell','color','b','fontweight','b','fontsize',18)
text(0,foo(4),'b = newBorn Cell','color',[161, 202, 241]./255,'fontweight','b','fontsize',18)
text(0,foo(5),'a = Apoptotic Cell','color','r','fontweight','b','fontsize',18)
text(0,foo(6),'o = Over Segmented','color','g','fontweight','b','fontsize',18)
text(0,foo(7),'u = Under Segmented','color','m','fontweight','b','fontsize',18)
text(0,foo(8),'j = Junk','color','y','fontweight','b','fontsize',18)
text(0,foo(9),'-> = Advance 1 Image','color','k','fontweight','b','fontsize',18)
text(0,foo(10),'<- = Previous Image','color','k','fontweight','b','fontsize',18)
text(0,foo(11),'s = Skip 10 images','color','k','fontweight','b','fontsize',18)
text(0,foo(12),'t = Toggle Image','color','k','fontweight','b','fontsize',18)
text(0,foo(13),'d = Delete Previous','color','k','fontweight','b','fontsize',18)
text(0,foo(14),'c = Increase Contrast','color','k','fontweight','b','fontsize',18)
text(0,foo(15),'x = Decrease Contrast','color','k','fontweight','b','fontsize',18)
text(0,foo(16),'q = Quit','fontweight','b','fontsize',18);
str = sprintf('Counts\nNuclear: %d\nOver Segmented: %d\nUnder Segmented: %d\nMitotic Cells: %d\nApoptotic Cells: %d\Newborn: %d',num_nuc,num_over,num_under,num_mito,num_apo,num_newborn);
text(0,.9,str,'fontsize',18)