<script>
  let files = ["File1.jpg", "File2.jpg", "File3.jpg"];
  
  function handleFileUpload(event) {
    // Placeholder function for file upload handling
    console.log("File uploaded:", event.target.files[0]);
  }
</script>

<main class="min-h-screen bg-gradient-to-r from-blue-500 to-teal-400 flex flex-col items-center p-8">
  <div class="bg-white rounded-lg shadow-lg p-8 w-full max-w-2xl">
    <h1 class="text-3xl font-bold mb-8 text-center text-gray-800">File List</h1>

    <ul class="mb-8 space-y-4">
      {#each files as file}
        <li class="bg-gray-100 rounded-md p-4 shadow-md flex items-center justify-between">
          <span class="text-gray-700">{file}</span>
          <button class="bg-red-500 text-white rounded px-4 py-2 hover:bg-red-600">
            Delete
          </button>
        </li>
      {/each}
    </ul>

    <div class="flex flex-col items-center">
      <label class="w-64 flex flex-col items-center px-4 py-6 bg-white text-blue-500 rounded-lg shadow-lg tracking-wide uppercase border border-blue-500 cursor-pointer hover:bg-blue-500 hover:text-white transition duration-300 ease-in-out transform hover:scale-105">
        <span class="mt-2 text-base leading-normal">Upload a file</span>
        <input type='file' class="hidden" on:change={handleFileUpload} />
      </label>
    </div>
  </div>
</main>

<style>
  .file-list {
    @apply list-disc list-inside;
  }
</style>
