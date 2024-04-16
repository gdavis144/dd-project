import { PencilIcon, PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import Link from 'next/link';
import { deleteSong as deleteSong, followArtist } from '@/app/lib/actions';

export function CreateSong() {
  return (
    <Link
      href="/dashboard/songs/create"
      className="flex h-10 items-center rounded-lg bg-blue-600 px-4 text-sm font-medium text-white transition-colors hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
    >
      <span className="hidden md:block">Create Song</span>{' '}
      <PlusIcon className="h-5 md:ml-4" />
    </Link>
  );
}

export function UpdateSong({ id }: { id: string }) {
  return (
    <Link
      href={`/dashboard/songs/${id}/edit`}
      className="rounded-md border p-2 hover:bg-gray-100"
    >
      <PencilIcon className="w-5" />
    </Link>
  );
}

export function DeleteSong({ id }: { id: string }) {
  const deleteSongWithId = deleteSong.bind(null, id);
  return (
    <form action={deleteSongWithId}>
      <button className="rounded-md border p-2 hover:bg-gray-100">
        <span className="sr-only">Delete</span>
        <TrashIcon className="w-5" />
      </button>
    </form>
  );
}

export function FollowArtist({ follower_id, artist_id }: { follower_id: string, artist_id: number }) {
  const followArtistId = followArtist.bind(null, follower_id, artist_id);
  return (
    <form action={followArtistId}>
      <button className="rounded-md border p-2 hover:bg-gray-100">
        <span className="sr-only">Follow</span>
        <PlusIcon className="w-5" />
      </button>
    </form>
  );
}
