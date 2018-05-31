#include <stdio.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_native_dialog.h>
#include <allegro5/allegro_primitives.h>

ALLEGRO_DISPLAY *display = NULL;

int scale_bitmap(
  ALLEGRO_BITMAP *src_bitmap,
  ALLEGRO_BITMAP *dst_bitmap,
  int src_width, int src_height,
  int dst_width, int dst_height);

void showError(char *msg) {
    al_show_native_message_box(
      display, "Error", "Error", msg,
      NULL, ALLEGRO_MESSAGEBOX_ERROR
    );
}

enum KEYNAME {UP, DOWN, LEFT, RIGHT};

int main(int argc, char **argv) {

   ALLEGRO_BITMAP *src_bitmap, *dst_bitmap;
   ALLEGRO_LOCKED_REGION *src_region, *dst_region;
   int src_width, src_height, dst_width, dst_height;
   ALLEGRO_TIMER *timer;
   ALLEGRO_EVENT_QUEUE *event_queue;
   ALLEGRO_EVENT ev;
   int redraw = 0;
   int key[4] = {0, 0, 0, 0};

   al_init();
   al_init_image_addon();
   al_install_keyboard();

   display = al_create_display(800,600);

   src_bitmap = al_load_bitmap("in.bmp");
   src_width = al_get_bitmap_width(src_bitmap);
   src_height = al_get_bitmap_height(src_bitmap);
   // printf("%d %d\n", region->pitch, region->pixel_size);

   dst_width = src_width*2;
   dst_height = src_height*2;
   dst_bitmap = al_create_bitmap(dst_width, dst_height);

   timer = al_create_timer(1.0 / 60.0);

   event_queue = al_create_event_queue();

   al_register_event_source(event_queue, al_get_display_event_source(display));
   al_register_event_source(event_queue, al_get_timer_event_source(timer));
   al_register_event_source(event_queue, al_get_keyboard_event_source());

   while(1) {
     if (ev.type == ALLEGRO_EVENT_TIMER) {
       redraw = 1;
     }
     else if(ev.type == ALLEGRO_EVENT_DISPLAY_CLOSE) {
       break;
     }
     else if (ev.type == ALLEGRO_EVENT_KEY_DOWN) {
       switch(ev.keyboard.keycode) {
         case ALLEGRO_KEY_UP:
           key[UP] = 1;
           break;

         case ALLEGRO_KEY_DOWN:
           key[DOWN] = 1;
           break;

          case ALLEGRO_KEY_RIGHT:
            key[RIGHT] = 1;
            break;

          case ALLEGRO_KEY_LEFT:
            key[LEFT] = 1;
            break;
       }
     }
     else if (ev.type == ALLEGRO_EVENT_KEY_UP) {
       switch(ev.keyboard.keycode) {
         case ALLEGRO_KEY_UP:
           key[UP] = 0;
           break;

         case ALLEGRO_KEY_DOWN:
           key[DOWN] = 0;
           break;

          case ALLEGRO_KEY_RIGHT:
            key[RIGHT] = 0;
            break;

          case ALLEGRO_KEY_LEFT:
            key[LEFT] = 0;
            break;
       }
     }

     if (key[UP]) {
       dst_height++;
       al_destroy_bitmap(dst_bitmap);
       dst_bitmap = al_create_bitmap(dst_width, dst_height);
     }

     if (key[DOWN] && dst_height > src_height) {
       dst_height--;
       al_destroy_bitmap(dst_bitmap);
       dst_bitmap = al_create_bitmap(dst_width, dst_height);
     }

     if (key[RIGHT]) {
       dst_width++;
       al_destroy_bitmap(dst_bitmap);
       dst_bitmap = al_create_bitmap(dst_width, dst_height);
     }

     if (key[LEFT] && dst_width > src_width) {
       dst_width--;
       al_destroy_bitmap(dst_bitmap);
       dst_bitmap = al_create_bitmap(dst_width, dst_height);
     }

     src_region = al_lock_bitmap(
       src_bitmap,
       ALLEGRO_PIXEL_FORMAT_BGR_888,
       ALLEGRO_LOCK_READWRITE);

     dst_region = al_lock_bitmap(
       dst_bitmap,
       ALLEGRO_PIXEL_FORMAT_BGR_888,
       ALLEGRO_LOCK_READWRITE);

     scale_bitmap(
       dst_region->data - dst_width * 3 * (dst_height - 1),
       src_region->data - src_width * 3 * (src_height - 1),
       src_width, src_height,
       dst_width, dst_height);

     al_unlock_bitmap(src_bitmap);
     al_unlock_bitmap(dst_bitmap);

     al_clear_to_color(al_map_rgb(0, 0, 0));
     al_draw_bitmap(dst_bitmap,0,0,0);

     al_flip_display();

     al_wait_for_event(event_queue, &ev);
   }

   al_destroy_display(display);
   al_destroy_bitmap(src_bitmap);

   return 0;
}
