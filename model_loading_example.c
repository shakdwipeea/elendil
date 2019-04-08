#include "raylib.h"

#define MAX_LIGHTS      8

typedef struct LightData {
    unsigned int id;        // Light unique id
    bool enabled;           // Light enabled
    int type;               // Light type: LIGHT_POINT, LIGHT_DIRECTIONAL, LIGHT_SPOT

    Vector3 position;       // Light position
    Vector3 target;         // Light direction: LIGHT_DIRECTIONAL and LIGHT_SPOT (cone direction target)
    float radius;           // Light attenuation radius light intensity reduced with distance (world distance)

    Color diffuse;          // Light diffuse color
    float intensity;        // Light intensity level

    float coneAngle;        // Light cone max angle: LIGHT_SPOT
} LightData, *Light;

// Light types
typedef enum { LIGHT_POINT, LIGHT_DIRECTIONAL, LIGHT_SPOT } LightType;

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
static Light lights[MAX_LIGHTS];            // Lights pool
static int lightsCount = 0;                 // Enabled lights counter
static int lightsLocs[MAX_LIGHTS][8];       // Lights location points in shader: 8 possible points per light: 
                                            // enabled, type, position, target, radius, diffuse, intensity, coneAngle


int main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    int screenWidth = 800;
    int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - obj model loading");

    Camera camera = { 0 };
    camera.position = (Vector3){ 4.0f, 2.0f, 4.0f };
    camera.target = (Vector3){ 0.0f, 1.8f, 0.0f };
    camera.up = (Vector3){ 0.0f, 1.0f, 0.0f };
    camera.fovy = 60.0f;
    camera.type = CAMERA_PERSPECTIVE;

    SetCameraMode(camera, CAMERA_FIRST_PERSON);
    //SetCameraMoveControls(87,83,68,65,87,83);

    Model model = LoadModel("/Users/rasra04/Documents/interior.obj");                 // Load OBJ model
    //Texture2D texture = LoadTexture("resources/models/castle_diffuse.png"); // Load model texture
    //model.materials[0].maps[MAP_DIFFUSE].texture = texture;                 // Set map diffuse texture
    Vector3 position = { 0.0f, 0.0f, 0.0f };                                // Set model position

    Light spotLight = CreateLight(LIGHT_SPOT, (Vector3){3.0f, 5.0f, 2.0f}, (Color){255, 255, 255, 255});
    spotLight->target = (Vector3){0.0f, 0.0f, 0.0f};
    spotLight->intensity = 2.0f;
    spotLight->diffuse = (Color){255, 100, 100, 255};
    spotLight->coneAngle = 60.0f;

    SetTargetFPS(60);   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        //...
        //----------------------------------------------------------------------------------

        UpdateCamera(&camera); 
        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(LIGHTGRAY);

            BeginMode3D(camera);

                DrawModel(model, position, 0.2f, WHITE);   // Draw 3d model with texture

                DrawLight(spotLight); 

                DrawGrid(10, 1.0f);         // Draw a grid

                DrawGizmo(position);        // Draw gizmo

            EndMode3D();

            DrawText("(c) Castle 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, GRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    //UnloadTexture(texture);     // Unload texture
    UnloadModel(model);         // Unload model

    DestroyLight(spotLight);

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    return 0;
}

