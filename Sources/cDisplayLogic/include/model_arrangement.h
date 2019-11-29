#ifndef MODEL_ARRANGEMENT
#define MODEL_ARRANGEMENT

#include <stdlib.h>
#include <stdio.h>

//  Default of a glyth on the screen for computing approximate size of rects for display on the screen
#define GLYPH_WDT_PXL 30
#define GLYPH_HGT_PXL 40


/*
 * Configurations for how to go about creating a rectangle for a model
 */
typedef struct _model_rect_config {
    int glyphWidth;
    int glythHeight;
} model_rect_config;

/*
 * Rectangle for display on the screen
 */
typedef struct _rect {
    float x;
    float y;
    float width;
    float height;
    struct _rect *label_rect;   //  Rect for holding the text of a label contained in this rectangle
    model_rect_config *config;  //  Configuration for working with this rect
} model_arrangement_rect;

/*
 * For queueing all rectangles in a set in order to do geometric calculations
 */
typedef struct _rect_node {
    model_arrangement_rect *rect;
    struct _rect_node *next;
} model_arrangement_rect_node;

model_arrangement_rect_node *model_arrangement_new_rect_node();
model_arrangement_rect_node *model_arrangement_new_rect_node() {
    model_arrangement_rect_node *ret = malloc(sizeof(model_arrangement_rect_node));
    ret->next = 0;
    ret->rect = malloc(sizeof(model_arrangement_rect));
    ret->rect->label_rect = 0;
    ret->rect->config = 0;

    return ret;
}

/*
 * Compute appropriate width and height for the given string
 */
model_arrangement_rect *model_arrangement_computeRectDimensionsFor(char *name, model_rect_config *config);
model_arrangement_rect *model_arrangement_computeRectDimensionsFor(char *name, model_rect_config *config) {

    int length = 0;
    do {
        if(*(name + (++length)) == '\0' ){
            break;
        }
    } while(1);

    int glyphWidth = config->glyphWidth;
    if(glyphWidth == 0) {
        glyphWidth = GLYPH_WDT_PXL;
    }
    int glyphHeight = config->glythHeight;
    if(glyphHeight == 0) {
        glyphHeight = GLYPH_HGT_PXL;
    }

    model_arrangement_rect *ret = malloc(sizeof(model_arrangement_rect));
    ret->height = (float)glyphHeight * 3;
    ret->width = (float)(length * glyphWidth);

    model_arrangement_rect *labelRect = malloc(sizeof(model_arrangement_rect));
    labelRect->width = (length * glyphWidth) -  glyphWidth;
    labelRect->height = glyphHeight*2;
    ret -> label_rect = labelRect;
    ret -> config = config;

    return ret;

}

/*
 * Compute optimal arrangement of the given nodes
 */
void model_arrangement_ArrangeRectangles(model_arrangement_rect_node *listOfNodes);
void model_arrangement_ArrangeRectangles(model_arrangement_rect_node *listOfNodes) {

    if(listOfNodes == NULL) {
        fprintf(stderr, "Node list was null!\n");
        return;
    }

    model_arrangement_rect_node *currentNode = listOfNodes;
    model_arrangement_rect *rect;

    float xDist = 0.0;  //  Current cursor position along X-axis
    float yDist = 0.0;  //  Current cursor position along Y-axis
    
    while (currentNode != NULL) {

        rect = currentNode -> rect;
        if(rect == NULL) {
            fprintf(stderr, "Node has a NULL rect!\n");
        }

        rect->x = xDist + 10.0;
        rect->y = yDist + 10.0;

        

        //  Now compute position of label if present
        if(rect -> label_rect != NULL) {

            model_arrangement_rect *labelRect = rect -> label_rect;
            float widthDifference = rect->width - labelRect -> width;

            //  TODO:  Make this configurable (see rect->config later on!)
            widthDifference /= 2;

            float heightDifference = rect->height - labelRect -> height;
            //  TODO:  Make this configurable (see rect->config later on!)
            heightDifference /= 2;

            printf("wDiff=%f, hDiff=%f (parentW=%f, parentH=%f vs labelW=%f, labelH=%f)\n", widthDifference, heightDifference, rect->width, rect->height, 
                labelRect->width, labelRect->height
            );

            labelRect -> x = (xDist + widthDifference);
            labelRect -> y = (yDist + heightDifference);
        }

        xDist += (rect->width)+10.0;

        currentNode = currentNode -> next;
    }

}

#endif