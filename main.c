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
  int dst_width, int dst_height,
  double *debug, int *debug_int, unsigned char *debug_char);

void showError(char *msg) {
    al_show_native_message_box(
      display, "Error", "Error", msg,
      NULL, ALLEGRO_MESSAGEBOX_ERROR
    );
}

enum KEYNAME {UP, DOWN, LEFT, RIGHT};

double SIZE_RATIO = 1;

int main(int argc, char **argv) {

   ALLEGRO_BITMAP *src_bitmap, *dst_bitmap;
   ALLEGRO_LOCKED_REGION *src_region, *dst_region;
   int src_width, src_height, dst_width, dst_height;
   ALLEGRO_TIMER *timer;
   ALLEGRO_EVENT_QUEUE *event_queue;
   ALLEGRO_EVENT ev;
   int redraw = 0;
   int key[4] = {0, 0, 0, 0};
   int running = 1;

   al_init();
   al_init_image_addon();
   al_install_keyboard();

   display = al_create_display(800,600);

   src_bitmap = al_load_bitmap("in.bmp");
   src_width = al_get_bitmap_width(src_bitmap);
   src_height = al_get_bitmap_height(src_bitmap);

   dst_width = src_width*SIZE_RATIO;
   dst_height = src_height*SIZE_RATIO;
   dst_bitmap = al_create_bitmap(dst_width, dst_height);

   timer = al_create_timer(1.0 / 30.0);

   event_queue = al_create_event_queue();

   al_register_event_source(event_queue, al_get_display_event_source(display));
   al_register_event_source(event_queue, al_get_timer_event_source(timer));
   al_register_event_source(event_queue, al_get_keyboard_event_source());

   al_start_timer(timer);

   while(running) {
     al_wait_for_event(event_queue, &ev);

     if (ev.type == ALLEGRO_EVENT_TIMER) {

       if (key[DOWN]) {
         dst_height += 5;
         al_destroy_bitmap(dst_bitmap);
         dst_bitmap = al_create_bitmap(dst_width, dst_height);
       }

       if (key[UP]) {
         dst_height -= 5;
         al_destroy_bitmap(dst_bitmap);
         dst_bitmap = al_create_bitmap(dst_width, dst_height);
       }

       if (key[RIGHT]) {
         dst_width += 5;
         al_destroy_bitmap(dst_bitmap);
         dst_bitmap = al_create_bitmap(dst_width, dst_height);
       }

       if (key[LEFT]) {
         dst_width -= 5;
         al_destroy_bitmap(dst_bitmap);
         dst_bitmap = al_create_bitmap(dst_width, dst_height);
       }

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

          case ALLEGRO_KEY_ESCAPE:
            running = 0;
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

     if (redraw && al_is_event_queue_empty(event_queue)) {

       src_region = al_lock_bitmap(
         src_bitmap,
         ALLEGRO_PIXEL_FORMAT_BGR_888,
         ALLEGRO_LOCK_READWRITE);

       dst_region = al_lock_bitmap(
         dst_bitmap,
         ALLEGRO_PIXEL_FORMAT_BGR_888,
         ALLEGRO_LOCK_READWRITE);

      // printf("%d %d\n", src_region->pitch, src_region->pixel_size);
      // printf("%d %d\n", dst_region->pitch, dst_region->pixel_size);
      // printf("%d %d\n", dst_width, dst_height);

      double debug = 123;
      int debug_int = 12345;
      unsigned char debug_char = 12;

       scale_bitmap(
         dst_region->data - dst_width * 3 * (dst_height - 1),
         src_region->data - src_width * 3 * (src_height - 1),
         src_width, src_height,
         dst_width, dst_height,
         &debug, &debug_int, &debug_char);

       // if (debug < 0)
        printf("%ff %d %d\n", debug, debug_int, debug_char);

       al_unlock_bitmap(src_bitmap);
       al_unlock_bitmap(dst_bitmap);

       al_clear_to_color(al_map_rgb(0, 0, 255));
       al_draw_bitmap(dst_bitmap,0,0,0);

       al_flip_display();

       redraw = 0;
     }
   }

   al_destroy_display(display);
   al_destroy_bitmap(src_bitmap);
   al_destroy_bitmap(dst_bitmap);
   al_destroy_timer(timer);
   al_destroy_event_queue(event_queue);

   return 0;
}
